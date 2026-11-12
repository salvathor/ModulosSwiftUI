//
//  UsuariosFactory.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

/// Ensambla el módulo de detalle con el ID seleccionado y el repositorio compartido.
/// Entrega la fábrica de ubicación para construir la siguiente pantalla.
@MainActor
final class DetalleUsuarioFactory {
    
    private let container: DIContainer
    
    // Nueva dependencia de ubicacion
    private let ubicacionFactory: UbicacionUsuarioFactory
    
    init(container: DIContainer, ubicacionFactory: UbicacionUsuarioFactory){
        self.container = container
        self.ubicacionFactory = ubicacionFactory
    }
    
    func makeDetalleUsuarioView(idUsuario: Int) -> DetalleUsuarioView {
        // 1. Obtener dependencia del container
        let repository = container.resolverUsuarioRepository()
        
        // 2. Crear el viewModel e inyectar la dependencia
        let viewModel = DetalleUsuarioViewModel(repository: repository, idUsuario: idUsuario)
        
        // 3. Construir y devolver la View
        return DetalleUsuarioView(viewModel: viewModel, ubicacionFactory: ubicacionFactory)
        
    }
    
}
