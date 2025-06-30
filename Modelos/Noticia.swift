import Foundation
import FirebaseFirestore


struct Noticia: Codable, Identifiable {
    
    @DocumentID var id: String?
    var titulo: String
    var descripcion: String
    var imagenURL: String
    
    // --- LA CORRECCIÓN FINAL ---
    // Cambiamos el tipo de 'Timestamp' a 'Double' para que coincida con el
    // número (milisegundos) que guarda la app de Android.
    var timestamp: Double
    
    // 'fechaExpiracion' se queda como 'Timestamp' porque Android sí lo guarda
    // como un objeto de fecha de Firebase.
    var fechaExpiracion: Timestamp
    
    // Modificamos la propiedad computada para que sepa crear una Fecha
    // a partir de los milisegundos.
    var fechaDeCreacion: Date {
        // Dividimos por 1000 para convertir de milisegundos a segundos.
        Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    var fechaDeExpiracion: Date {
        fechaExpiracion.dateValue()
    }
}
