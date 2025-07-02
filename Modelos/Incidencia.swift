//
//  Incidencia.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import Foundation
import FirebaseFirestore

struct Incidencia: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var titulo: String
    var descripcion: String
    var correo: String
    var fotoUrl: String? // La URL de la imagen puede no existir
    var tipo: String

    // Mapeamos los nombres de los campos de Firestore a nuestras propiedades
    enum CodingKeys: String, CodingKey {
        case id
        case titulo = "Titulo"
        case descripcion = "Descripcion"
        case correo = "Correo"
        case fotoUrl // El nombre coincide
        case tipo = "tipo" // El nombre coincide
    }
}
