//
//  UbicacionUsuarioFactory.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 12/11/26.
//

import SwiftUI

/// Ensambla la pantalla del mapa inyectando el repositorio y LocationService.
/// La vista no necesita crear ni configurar CLLocationManager.
@MainActor
final class UbicacionUsuarioFactory {
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func makeUbicacionView(usuarioId: Int) -> UbicacionUsuarioView {
        // 1.Resolver dependencias
        let respository = container.resolverUsuarioRepository()
        let locationService = container.resolverUsuarioService()
        // 2.Crear el ViewModel
        let viewModel = UbicacionUsuarioViewModel(usuariId: usuarioId, repository: respository, locationService: locationService)
        // 3. Construir el View
        return UbicacionUsuarioView.init(viewModel: viewModel)
    }
    
}

