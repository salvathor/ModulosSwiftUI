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

@MainActor
final class UbicacionUsuarioViewModel: ObservableObject {
    
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
        
        // Solicitud
        let request = MKDirections.Request()
        request.source = origen
        request.destination = destino
        request.transportType = .automobile
            
        // Crear el servicio de rutas.
        let directions = MKDirections(request: request)
            
        // Solicitar ruta a MapKit
        do {
            let response = try await directions.calculate()
            
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
