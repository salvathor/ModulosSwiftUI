//
//  ModulosSwiftUIApp.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

@main
struct ModulosSwiftUIApp: App {
    
    // 2. Crear Factory Usuarios
    private let usuariosFactory: UsuariosFactory
    
    init(){
        
        // 1. Crear DIContainer
        let container = DIContainer()
        
        // 2.1 Crear Factory Detalle
        let detalleFactory = DetalleUsuarioFactory(container: container)
        
        self.usuariosFactory = UsuariosFactory(
            container: container, detalleUsuarioFactory: detalleFactory
        )
    }
    
    var body: some Scene {
        WindowGroup {
            // 3. Construir el modulo usuarios
            usuariosFactory.makeUsuariosView()
        }
    }
}
