import Foundation
import FirebaseFirestore
import FirebaseFirestore

@MainActor
class TelefonosViewModel: ObservableObject {
    
    @Published var telefonos = [Telefono]()
    
    private let db = Firestore.firestore()
    private let telefonosRef = Firestore.firestore().collection("pueblos/Figueruelas/Telefonos")
    
    // --- FUNCIÓN DE CARGA CON DEPURACIÓN DETALLADA ---
    func fetchTelefonos() async {
        print("--- DEBUG: Iniciando fetchTelefonos() ---")
        
        do {
            let querySnapshot = try await telefonosRef.getDocuments()
            print("--- DEBUG: Consulta a Firestore completada. Se encontraron \(querySnapshot.documents.count) documentos.")
            
            if querySnapshot.isEmpty {
                print("--- DEBUG: La colección de teléfonos está vacía en Firestore o la ruta es incorrecta.")
                return // Salimos de la función si no hay nada que procesar
            }
            
            // Intentamos decodificar los documentos y guardamos los resultados
            let decodedTelefonos = querySnapshot.documents.compactMap { document -> Telefono? in
                do {
                    // Intenta convertir el documento en un objeto Telefono
                    let telefono = try document.data(as: Telefono.self)
                    print("--- DEBUG: Documento \(document.documentID) decodificado con éxito: \(telefono.nombre)")
                    return telefono
                } catch {
                    // Si falla la decodificación, imprime el error detallado
                    print("--- DEBUG: ¡ERROR! No se pudo decodificar el documento \(document.documentID). Error: \(error)")
                    return nil
                }
            }
            
            // Actualizamos la propiedad que la vista está observando
            self.telefonos = decodedTelefonos
            print("--- DEBUG: ViewModel actualizado con \(self.telefonos.count) teléfonos.")
            
        } catch {
            // Si la consulta inicial a Firestore falla (ej: por permisos incorrectos)
            print("--- DEBUG: ¡ERROR GRAVE! La consulta getDocuments() falló: \(error.localizedDescription)")
        }
    }
    
    // Las funciones de añadir y borrar no cambian
    func addTelefono(nombre: String, numero: String) async {
        let nuevoTelefono = Telefono(nombre: nombre, numero: numero)
        do {
            try telefonosRef.addDocument(from: nuevoTelefono)
            await fetchTelefonos()
        } catch {
            print("Error al añadir el teléfono: \(error.localizedDescription)")
        }
    }
    
    func deleteTelefono(at offsets: IndexSet) {
        let telefonosABorrar = offsets.map { self.telefonos[$0] }
        for telefono in telefonosABorrar {
            if let documentId = telefono.id {
                telefonosRef.document(documentId).delete()
            }
        }
        telefonos.remove(atOffsets: offsets)
    }
}
