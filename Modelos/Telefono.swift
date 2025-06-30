//
//  Telefono.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 29/6/25.
//

import Foundation
import FirebaseFirestore

struct Telefono: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // El ID del documento de Firestore
    var nombre: String
    var numero: String
}
