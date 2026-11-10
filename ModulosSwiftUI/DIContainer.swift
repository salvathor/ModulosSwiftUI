//
//  DIContainer.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

//MARK: DI Container

final class DIContainer{
    
    private let usuarioRepository: any UsuarioRepository
    
    init(){
        // Registro de dependencias
        self.usuarioRepository =  MockUsuarioRepository()
    }
    
    func resolverUsuarioRepository() -> any UsuarioRepository {
        usuarioRepository
    }
    
}
