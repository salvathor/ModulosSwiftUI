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
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(viewModel: UbicacionUsuarioViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func enfocarPuntos(){
        guard let usuario = viewModel.usuario else {
            return
        }
        
        let destino = usuario.coordenada
        
        guard let actual = viewModel.ubicacionActual?.coordinate else {
            cameraPosition = .region(
                MKCoordinateRegion(
                center: destino,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.02,
                    longitudeDelta: 0.02
                    )
                )
            )
            return
        }
        
        // Calcular un centro entre ambos puntos.
        let centro = CLLocationCoordinate2D(
            latitude: ((destino.latitude + actual.latitude) / 2),
            longitude: ((destino.longitude + actual.longitude) / 2)
        )
        
        //Calcular los valores delta
        let latDel = abs(destino.latitude - actual.latitude) * 1.2
        let lonDel = abs(destino.longitude - actual.longitude) * 1.2
        
        cameraPosition = .region(
            MKCoordinateRegion(
            center: centro,
            span: MKCoordinateSpan(
                latitudeDelta: latDel,
                longitudeDelta: lonDel)
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 16){
            if let usuario = viewModel.usuario {
                
                // Seccion Mapa
                Text("Ubicación de \(usuario.nombre)")
                    .font(.title2.bold())
                Map(position:$cameraPosition){
                    // Marcador del usuario
                    Marker(
                        usuario.nombre,
                        coordinate: usuario.coordenada
                        )
                    .tint(.red)
                    // Marcador de mi ubicacion
                    if let ubicacion = viewModel.ubicacionActual {
                        Marker(
                            "Mi ubicación",
                            coordinate: ubicacion.coordinate
                        )
                        .tint(.blue)
                    }
                }
                .frame(height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onAppear{
                    /*cameraPosition = .region(MKCoordinateRegion(
                        center: usuario.coordenada, span: MKCoordinateSpan(
                            latitudeDelta: 1, longitudeDelta: 1
                        )
                    ))*/
                    enfocarPuntos()
                }
                .onChange(of: viewModel.distanciaKilometros) { _ in
                    enfocarPuntos()
                }
                
                // Mostrar distancia entre los dos puntos.
                if let distancia = viewModel.distanciaKilometros {
                    Text("Distancia: \(distancia, specifier: "%.2f") km")
                        .font(.headline)
                } else {
                    Text("Obtén tu ubicación para calcular la distancia")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Boton mi ubicación.
                Button {
                    viewModel.obtenerMiUbicacion()
                } label: {
                    if viewModel.cargando {
                        ProgressView()
                    }else{
                        Label(
                            "Obtener mi ubicacion",
                            systemImage: "location.fill"
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.cargando)
                
                // Mostrar error de CLLocation
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
            } else {
                Text("Usuario no encontrado")
            }
        }
        .padding()
        .navigationTitle("Ubicación")
    }
}
