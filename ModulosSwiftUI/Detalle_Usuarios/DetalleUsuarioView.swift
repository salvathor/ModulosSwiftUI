//
//  DetalleUsuarioView.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI
import Kingfisher

struct DetalleUsuarioView: View {
    
    @State private var resultado = "Ubicacion no solicitada"
    @State private var cargando = false
    
    private let locationService = CoreLocationService()
    
    @StateObject private var viewModel: DetalleUsuarioViewModel
    
    init(viewModel: DetalleUsuarioViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group{
            if let usuario = viewModel.usuario{
                VStack{
                    KFImage(URL(string: usuario.imagen)!)
                        .resizable()
                        .frame(width: 200,height: 200)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    Text(usuario.nombre)
                        .font(.largeTitle.bold())
                    LabeledContent("Correo", value: usuario.correo)
                    LabeledContent("Telefono", value: usuario.telefono)
                    Text("Prueba de CoreLocation")
                        .font(.title)
                        .bold()
                    Text(resultado)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                    Button("Obtener ubicación"){
                        obtenerUbicacion()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(cargando)
                    
                    if cargando {
                        ProgressView("Obteniendo ubicación...")
                    }
                    
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
    
    private func obtenerUbicacion(){
        cargando = true
        resultado = "Solicitando ubicación"
        
        locationService.solicitarUbicacion { res in
            cargando = false
            
            switch res {
            case .success(let ubicacion):
                resultado = """
                Latitud: \(ubicacion.coordinate.latitude)
                Longitud: \(ubicacion.coordinate.longitude)
                Precision: \(ubicacion.horizontalAccuracy) metros
                """
            case .failure(let error):
                resultado = "Error \(error.localizedDescription)"
            }
        }
    }
    
}


