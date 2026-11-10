//
//  DetalleUsuarioView.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

struct DetalleUsuarioView: View {
    
    @StateObject private var viewModel: DetalleUsuarioViewModel
    
    init(viewModel: DetalleUsuarioViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group{
            if let usuario = viewModel.usuario{
                VStack{
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    Text(usuario.nombre)
                        .font(.largeTitle.bold())
                    LabeledContent("Correo", value: usuario.correo)
                    LabeledContent("Telefono", value: usuario.telefono)
                    Spacer()
                }
                .padding()
            }else{
                Text("Usuario no encontrado")
                Image(systemName: "person.crop.circle.badge.questionmark")
            }
        }
        .navigationTitle("Usuario Detalle")
        .task {
            viewModel.cargarDetalleUsuario()
        }
    }
    
    
}
