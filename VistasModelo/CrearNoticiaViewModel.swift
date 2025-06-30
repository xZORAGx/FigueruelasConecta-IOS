import Foundation
import SwiftUI
import PhotosUI
import FirebaseFirestore

@MainActor
class CrearNoticiaViewModel: ObservableObject {
    
    // --- Propiedades para enlazar con la Vista ---
    @Published var titulo = ""
    @Published var descripcion = ""
    @Published var imagenSeleccionada: UIImage?
    
    @Published var pickerItem: PhotosPickerItem? {
        didSet {
            Task {
                do {
                    if let data = try await pickerItem?.loadTransferable(type: Data.self) {
                        self.imagenSeleccionada = UIImage(data: data)
                    }
                } catch {
                    print("Error al cargar la imagen seleccionada: \(error)")
                }
            }
        }
    }
    
    // --- Propiedades para gestionar el estado de la vista ---
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var guardadoExitoso = false
    
    private let noticiasRef = Firestore.firestore().collection("pueblos/Figueruelas/Noticias")
    
    func guardarNoticia() async {
        guard !titulo.isEmpty, !descripcion.isEmpty else {
            self.errorMessage = "El título y la descripción no pueden estar vacíos."
            return
        }
        
        self.isLoading = true
        var imagenURLParaGuardar = ""
        
        do {
            // 1. Subir imagen si existe
            if let image = imagenSeleccionada {
                let url = try await StorageManager.shared.subirImagen(image, aCarpeta: "Noticias")
                imagenURLParaGuardar = url.absoluteString
            }
            
            // 2. Preparar datos
            let datosNoticia: [String: Any] = [
                "titulo": titulo,
                "descripcion": descripcion,
                "imagenURL": imagenURLParaGuardar,
                "timestamp": Date().timeIntervalSince1970 * 1000,
                "fechaExpiracion": Timestamp(date: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
            ]
            
            // 3. Guardar en Firestore
            try await noticiasRef.addDocument(data: datosNoticia)
            
            // --- ACTUALIZACIÓN ---
            // 4. Enviamos la notificación para avisar a otras partes de la app.
            NotificationCenter.default.post(name: .noticiaCreada, object: nil)
            
            // 5. Actualizar el estado a "éxito" para cerrar la vista.
            self.isLoading = false
            self.guardadoExitoso = true
            
        } catch {
            self.isLoading = false
            self.errorMessage = "Error al guardar la noticia: \(error.localizedDescription)"
        }
    }
}
