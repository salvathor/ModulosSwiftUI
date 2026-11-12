//
//  UsuariosFactory.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

/// Factory del listado: resuelve dependencias, crea el ViewModel y lo inyecta
/// en la vista. La fábrica de detalle permite construir el destino de navegación.
@MainActor
final class UsuariosFactory {
    
    private let container: DIContainer
    private let detalleFactory: DetalleUsuarioFactory
    
    init(container: DIContainer, detalleUsuarioFactory: DetalleUsuarioFactory){
        self.container = container
        self.detalleFactory = detalleUsuarioFactory
    }
    
    func makeUsuariosView() -> UsuariosView {
        // 1. Obtener dependencia del container
        let repository = container.resolverUsuarioRepository()
        
        // 2. Crear el viewModel e inyectar la dependencia
        let viewModel = UsuariosViewModel(repository: repository)
        
        // 3. Construir y devolver la View
        return UsuariosView(viewModel: viewModel, detalleFactory: detalleFactory)
        
    }
    
}
