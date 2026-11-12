//
//  DIContainer.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

//MARK: DI Container

/// Contenedor de inyección de dependencias (DI).
/// Centraliza las implementaciones concretas y devuelve sus protocolos para
/// que los ViewModels no dependan directamente del mock ni de CLLocationManager.
/// Conserva un repositorio y un servicio de ubicación compartidos por las fábricas.
/// Para pruebas, los ViewModels pueden recibir otras implementaciones al iniciarse.
final class DIContainer{
    
    private let usuarioRepository: any UsuarioRepository
    
    // Nueva constante para el CoreLocationService
    private let locationService: any LocationService
    
    init(){
        // Registro de dependencias
        self.usuarioRepository =  MockUsuarioRepository()
        self.locationService = CoreLocationService()
    }
    
    func resolverUsuarioRepository() -> any UsuarioRepository {
        usuarioRepository
    }
    
    func resolverUsuarioService() -> any LocationService {
        locationService
    }
    
}
