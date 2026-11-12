//
//  ModulosSwiftUIApp.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

// MARK: - Arquitectura: MVVM por funcionalidades
// Model: Usuario representa los datos; UsuarioRepository abstrae su origen.
// View: las pantallas SwiftUI muestran estado y envían acciones al ViewModel.
// ViewModel: prepara los datos y coordina el repositorio y los servicios.
// Cada carpeta funcional agrupa View, ViewModel y Factory; son módulos lógicos
// dentro del mismo target, no paquetes independientes.
//
// La aplicación es el punto de composición: crea el contenedor y conecta las
// fábricas en el orden Ubicación -> Detalle -> Usuarios. La navegación recorre
// ese flujo en sentido inverso: listado -> detalle -> mapa.
// Las fábricas construyen pantallas; DIContainer conserva las dependencias.
// Combine comunica cambios de estado a SwiftUI; Core Location obtiene la
// posición del dispositivo y MapKit presenta el mapa y solicita rutas.
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
