//
//  UbicacionUsuarioView.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 12/11/26.
//

import SwiftUI
import MapKit

struct UbicacionUsuarioView: View {
    
    // SwiftUI conserva este ObservableObject durante la identidad de la vista
    // y observa los cambios publicados por Combine.
    @StateObject private var viewModel: UbicacionUsuarioViewModel
    // La cámara es estado de presentación local. .automatic deja que MapKit
    // determine inicialmente el encuadre de los elementos del mapa.
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(viewModel: UbicacionUsuarioViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MKCoordinateRegion combina centro y amplitud angular (span, en grados).
    // Este encuadre sencillo usa los extremos; no contempla el cruce del
    // antimeridiano ni garantiza incluir todas las curvas de una ruta.
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
        
        // El factor 1.2 agrega un 20 % de margen a la separación de los puntos.
        // Los deltas expresan grados de latitud/longitud, no kilómetros.
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
                // El binding ($) permite mover la cámara desde el código y recibir
                // los cambios causados por los gestos sobre el mapa.
                Map(position:$cameraPosition){
                    // Marcador del usuario
                    Marker(
                        usuario.nombre,
                        coordinate: usuario.coordenada
                        )
                    .tint(.red)
                    // Este Marker representa la última medición del servicio;
                    // no obtiene la ubicación ni sigue al dispositivo por sí mismo.
                    // Marcador de mi ubicacion
                    if let ubicacion = viewModel.ubicacionActual {
                        Marker(
                            "Mi ubicación",
                            coordinate: ubicacion.coordinate
                        )
                        .tint(.blue)
                    }
                    // MapPolyline dibuja la geometría calculada por MKDirections.
                    // Dibujar Ruta
                    if let ruta = viewModel.ruta {
                        MapPolyline(ruta.polyline)
                            .stroke(.blue, lineWidth: 4)
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
                
                if let ruta = viewModel.ruta {
                    VStack(spacing:8){
                        Text("Distancia por carretera: " + String(format: "%.2f km", ruta.distance / 1000))
                        Text("Tiempo estimado: " + String(format: "%.0f min.", ruta.expectedTravelTime / 60))
                    }
                    .font(.headline)
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
                
                // Boton calcular ruta
                Button("Calcular Ruta"){
                    // Task permite invocar el método async desde la acción del botón.
                    Task{
                        await viewModel.calculaRuta()
                        //Ajustar la camara
                        if let ruta = viewModel.ruta {
                            // El rectángulo del trazado encuadra la ruta completa.
                            cameraPosition = .rect(ruta.polyline.boundingMapRect)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.ubicacionActual == nil)
                
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
