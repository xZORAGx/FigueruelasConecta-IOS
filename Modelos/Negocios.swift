//
//  Negocios.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 4/7/25.
//

// 📂 Modelos/Negocio.swift

import Foundation
import FirebaseFirestore

struct Negocio: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var titulo: String
    var logoUrl: String
    var adminUID: String // UID del usuario dueño del negocio
    
    // Lo hacemos Hashable para poder usarlo en Sets, útil para las selecciones.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Negocio, rhs: Negocio) -> Bool {
        lhs.id == rhs.id
    }
}
