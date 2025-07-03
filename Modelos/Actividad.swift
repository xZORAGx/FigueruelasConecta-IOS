//
//  Actividad.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 3/7/25.
//

//  FigueruelasConecta/Modelos/Actividad.swift

import Foundation
import FirebaseFirestore

// Asegúrate de que tu modelo Actividad se vea así.
// Es el mismo que usamos en otras partes, lo cual es perfecto para reutilizar código.
struct Actividad: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var titulo: String
    var imageUrl: String? // La URL puede ser de una imagen o un PDF
    var fechaExpiracion: Timestamp?
}
