//
//  Partido.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 3/7/25.
//

//  FigueruelasConecta/Modelos/Partido.swift

import Foundation
import FirebaseFirestore

struct Partido: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var equipo1: String
    var equipo2: String
    var fecha: String
    var deporte: String
    var categoria: String
    var diaSemana: String
    var resultado: String
    // Guardamos la fecha de expiración para futuras limpiezas automáticas
    var fechaExpiracion: Timestamp?
}
