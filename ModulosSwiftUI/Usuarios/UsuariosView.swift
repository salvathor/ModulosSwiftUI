//
//  UsuariosView.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI
import Kingfisher

struct UsuariosView: View {
    
    @StateObject private var viewModel: UsuariosViewModel
    
    private let detalleFactory: DetalleUsuarioFactory
    
    init(viewModel: UsuariosViewModel, detalleFactory: DetalleUsuarioFactory){
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detalleFactory = detalleFactory
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.usuarios){ usuario in
                NavigationLink {
                    detalleFactory.makeDetalleUsuarioView(idUsuario: usuario.id)
                } label: {
                    Label(usuario.nombre, systemImage: "person.circle")
                }
                //Text(usuario.nombre)
            }
            .navigationTitle("Usuarios")
            .task{
                viewModel.cargarUsuarios()
            }
        }
    }
    
    
}

