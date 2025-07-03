//
//  Deporte.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 3/7/25.
//

//  FigueruelasConecta/Modelos/Deporte.swift

import Foundation
import FirebaseFirestore

struct Deporte: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var nombre: String
    var emoji: String
    var filtro: String // Usado para las queries en la colección 'Partidos'
}
