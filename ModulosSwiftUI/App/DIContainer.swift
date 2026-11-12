//
//  DIContainer.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

//MARK: DI Container

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
