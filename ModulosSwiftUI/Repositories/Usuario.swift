//
//  Usuario.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

//MARK: MODELO

/// Modelo de datos. Identifiable proporciona identidad para las filas de SwiftUI;
/// Hashable permite comparar y utilizar valores en colecciones que requieren hash.
struct Usuario: Identifiable, Hashable{
    let id: Int
    let nombre: String
    let correo: String
    let telefono: String
    let imagen: String
    
    //Nuevas propiedades
    let latitud: Double
    let longitud: Double
    
    // CLLocationCoordinate2D es un tipo de Core Location con latitud y longitud
    // en grados; MapKit también lo utiliza para ubicar marcadores y destinos.
    // Estas coordenadas pertenecen al registro, no son la ubicación del dispositivo.
    var coordenada: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
    
}

//MARK: Abstraccion

/// Patrón Repository: define cómo consultar usuarios sin exponer su almacenamiento.
/// Actualmente las consultas son síncronas y el contenedor proporciona datos en memoria.
protocol UsuarioRepository{
    func obtenerUsuarios() -> [Usuario]
    func obtenerUsuario(id:Int) -> Usuario
}

//MARK: Mock - Implementacion concreta

private var usuarios:[Usuario] = [
    Usuario(id: 1, nombre: "Ana", correo: "correo1@mail.com", telefono: "555555", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png", latitud: 20.6843, longitud: -88.5678),
    Usuario(id: 2, nombre: "Carlos", correo: "correo2@mail.com", telefono: "666666", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png", latitud: 41.8902, longitud: 12.4922),
    Usuario(id: 3, nombre: "María", correo: "correo3@mail.com", telefono: "777777", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png", latitud: -13.1631, longitud: -72.5450)
]

/// Implementación de ejemplo con datos fijos; no consulta una API ni una base de datos.
final class MockUsuarioRepository: UsuarioRepository {
    
    func obtenerUsuario(id: Int) -> Usuario {
        usuarios.first {$0.id == id}!
    }
    
    func obtenerUsuarios() -> [Usuario] {
        usuarios
    }
}


