//
//  UbicacionUsuarioView.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 12/11/26.
//

import SwiftUI
import MapKit

struct UbicacionUsuarioView: View {
    
    @StateObject private var viewModel: UbicacionUsuarioViewModel
    
    init(viewModel: UbicacionUsuarioViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16){
            if let usuario = viewModel.usuario {
                Text("Ubicación de \(usuario.nombre)")
                    .font(.title2.bold())
                Map{
                    Marker(
                        usuario.nombre,
                        coordinate: usuario.coordenada
                        )
                    .tint(.red)
                }
                .frame(height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            } else {
                Text("Usuario no encontrado")
            }
        }
        .padding()
        .navigationTitle("Ubicación")
    }
}
