//
//  UbicacionUsuarioViewModel.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 11/11/26.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class UbicacionUsuarioViewModel: ObservableObject {
    
    @Published private(set) var usuario: Usuario?
    @Published private(set) var ubicacionActual: CLLocation?
    @Published private(set) var errorMessage: String?
    @Published private(set) var cargando = false
    
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
    
}
