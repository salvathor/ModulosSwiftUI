//
//  DetalleUsuarioViewModel.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI
import Combine

/// Carga el registro seleccionado a través del contrato del repositorio.
/// @Published notifica el cambio a SwiftUI mediante ObservableObject (Combine).
/// private(set) impide que la vista modifique directamente el usuario.
@MainActor
final class DetalleUsuarioViewModel: ObservableObject {
    
    @Published private(set) var usuario: Usuario?
    
    private let idUsuario: Int
    private let repository: any UsuarioRepository
    
    init(repository: any UsuarioRepository, idUsuario: Int){
        self.repository = repository
        self.idUsuario = idUsuario
    }
    
    func cargarDetalleUsuario(){
        usuario = repository.obtenerUsuario(id: idUsuario)
    }
    
}
