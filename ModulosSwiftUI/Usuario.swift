//
//  Usuario.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 10/11/26.
//

import SwiftUI

//MARK: MODELO

struct Usuario: Identifiable{
    let id: Int
    let nombre: String
    let correo: String
    let telefono: String
    let imagen: String
}

//MARK: Abstraccion

protocol UsuarioRepository{
    func obtenerUsuarios() -> [Usuario]
    func obtenerUsuario(id:Int) -> Usuario
}

//MARK: Mock - Implementacion concreta

private var usuarios:[Usuario] = [
    Usuario(id: 1, nombre: "Ana", correo: "correo1@mail.com", telefono: "555555", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png"),
    Usuario(id: 2, nombre: "Carlos", correo: "correo2@mail.com", telefono: "666666", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png"),
    Usuario(id: 3, nombre: "María", correo: "correo3@mail.com", telefono: "777777", imagen: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Linux_mascot_tux.png")
]

final class MockUsuarioRepository: UsuarioRepository {
    
    func obtenerUsuario(id: Int) -> Usuario {
        usuarios.first {$0.id == id}!
    }
    
    func obtenerUsuarios() -> [Usuario] {
        usuarios
    }
}


