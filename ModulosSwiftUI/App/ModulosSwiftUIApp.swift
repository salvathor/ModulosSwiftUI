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
        
        // 1.3 Crear Factory Ubicacion
        let ubicacionFactory = UbicacionUsuarioFactory(container: container)
        
        // 1.2 Crear Factory Detalle
        let detalleFactory = DetalleUsuarioFactory(container: container, ubicacionFactory: ubicacionFactory)
        
        // 1.1 Fabrica de los usuarios
        self.usuariosFactory = UsuariosFactory(
            container: container, detalleUsuarioFactory: detalleFactory)
        
    }
    
    var body: some Scene {
        WindowGroup {
            // 3. Construir el modulo usuarios
            usuariosFactory.makeUsuariosView()
        }
    }
}
