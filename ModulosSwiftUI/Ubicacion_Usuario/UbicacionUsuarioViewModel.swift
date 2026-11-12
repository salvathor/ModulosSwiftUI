//
//  UbicacionUsuarioViewModel.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 11/11/26.
//

import Foundation
import Combine
import CoreLocation
import MapKit

/// ViewModel de ubicación: coordina datos, localización y cálculo de rutas.
/// MainActor aísla los cambios de estado que consume la interfaz.
@MainActor
final class UbicacionUsuarioViewModel: ObservableObject {
    
    // Combine: ObservableObject expone objectWillChange y @Published notifica
    // antes de modificar estas propiedades. SwiftUI observa el objeto mediante
    // @StateObject y vuelve a evaluar la vista cuando cambia su estado.
    // private(set) permite leer desde la vista, pero reserva la escritura al ViewModel.
    // Aquí no hay suscripciones sink ni AnyCancellable: SwiftUI observa por nosotros.
    @Published private(set) var usuario: Usuario?
    @Published private(set) var ubicacionActual: CLLocation?
    @Published private(set) var errorMessage: String?
    @Published private(set) var cargando = false
    @Published private(set) var ruta: MKRoute?
    
    private var usuarioID: Int
    private var repositorio: UsuarioRepository
    private var locationService: LocationService
    
    init(
        usuariId: Int,
        repository: UsuarioRepository,
        locationService: LocationService
    ){
        self.usuarioID = usuariId
        self.repositorio = repository
        self.locationService = locationService
        
        self.usuario = repository.obtenerUsuario(id: usuariId)
    }
    
    // Obtener ubicacion local
    func obtenerMiUbicacion(){
        
        cargando = true
        errorMessage = nil
        
        // El servicio usa un callback, no un publisher de Combine. La captura
        // débil evita que el closure retenido por el servicio retenga al ViewModel.
        locationService.solicitarUbicacion { [weak self] resultado in
            
            guard let self else {
                return
            }
            
            self.cargando = false
            
            switch resultado {
            case .success(let ubicacion):
                self.ubicacionActual = ubicacion
            case .failure(let error):
                self.ubicacionActual = nil
                self.errorMessage = error.localizedDescription
            }
            
        }
    }
    
    // Calcular distancia
    
    // Propiedad derivada: no necesita @Published porque depende de propiedades
    // publicadas. CLLocation.distance devuelve metros de distancia geográfica
    // entre puntos sobre la Tierra, sin seguir calles; se convierten a kilómetros.
    var distanciaKilometros: Double? {
        
        guard
            let usuario,
            let ubicacionActual
        else {
            return nil
        }
        
        let destino = CLLocation(
            latitude: usuario.latitud,
            longitude: usuario.longitud
        )
        
        let metros = ubicacionActual.distance(from: destino)
        
        return metros / 1000
    }
    
    // Metodo para calcular la ruta
    func calculaRuta() async {
        // 1. Validar que tenemos los dos puntos (usuario y dispositivo)
        guard
            let usuario,
            let ubicacionActual
        else{
            errorMessage = "Primero obten tu ubicación."
            return
        }
        
        // MKMapItem representa un lugar para MapKit; MKPlacemark lo construye
        // a partir de coordenadas. El origen es el dispositivo y el destino es
        // la ubicación almacenada del usuario seleccionado.
        // Origen
        let origen = MKMapItem(
            placemark: MKPlacemark(
                coordinate: ubicacionActual.coordinate
            )
        )
        
        // Destino
        let destino = MKMapItem(
            placemark: MKPlacemark(
                coordinate: usuario.coordenada
            )
        )
        
        // La petición define los extremos y el transporte (.automobile: automóvil).
        // Solicitud
        let request = MKDirections.Request()
        request.source = origen
        request.destination = destino
        request.transportType = .automobile
            
        // Crear el servicio de rutas.
        let directions = MKDirections(request: request)
            
        // Solicitar ruta a MapKit
        do {
            // MapKit consulta su servicio de rutas: puede fallar por conectividad
            // o falta de una ruta disponible. await suspende esta tarea sin bloquear
            // la interfaz; al continuar, el estado sigue aislado en MainActor.
            let response = try await directions.calculate()
            
            // MKRoute incluye polyline (trazado), distance (metros),
            // expectedTravelTime (segundos) y steps (indicaciones).
            // La distancia de ruta sí sigue el recorrido, a diferencia de distance(from:).
            // Obtener primera ruta
            ruta = response.routes.first
            
            if let ruta {
                print("Distancia: \(ruta.distance / 1000) km.")
                print("Tiempo: \(ruta.expectedTravelTime / 60) minutos.")
                print("Primer paso: \(ruta.steps[2].instructions)")
            }
            
        } catch {
            ruta = nil
            errorMessage = error.localizedDescription
            print("Error al calcular ruta: \(error)")
        }
    }
    
}
