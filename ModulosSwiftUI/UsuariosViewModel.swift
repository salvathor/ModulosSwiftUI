//
//  UsuariosViewModel.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI
import Combine

@MainActor
final class UsuariosViewModel: ObservableObject {
    
    @Published private(set) var usuarios: [Usuario] = []
    
    private let repository: any UsuarioRepository
    
    init(repository: any UsuarioRepository){
        self.repository = repository
    }
    
    func cargarUsuarios(){
        usuarios = repository.obtenerUsuarios()
            .sorted{
                $0.nombre < $1.nombre
            }
    }
    
}
