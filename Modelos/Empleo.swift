//
//  Empleo.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import Foundation
import FirebaseFirestore

// El modelo Empleo que se corresponde con tu colección en Firestore.
// Conforme a Codable para la (de)codificación automática y a Identifiable para usarlo en Listas de SwiftUI.
struct Empleo: Codable, Identifiable {
    
    // @DocumentID nos permite obtener el ID del documento de Firestore automáticamente.
    @DocumentID var id: String?
    
    var titulo: String
    var descripcion: String
    var imagenUrl: String? // La URL de la imagen en Firebase Storage
    
    // @ServerTimestamp se encarga de rellenar la fecha automáticamente al crear el documento en Firestore.
    @ServerTimestamp var fechaCreacion: Timestamp?
    
    // Manejaremos la fecha de expiración como un Timestamp también para consistencia.
    var fechaExpiracion: Timestamp?
    

}
