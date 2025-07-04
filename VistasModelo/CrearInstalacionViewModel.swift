import SwiftUI
import PhotosUI

// Estructura para manejar el estado del horario en el formulario
struct HorarioDiaState {
    var activo: Bool = false
    var apertura: Date = Date()
    var cierre: Date = Date()
}

@MainActor
class CrearInstalacionViewModel: ObservableObject {
    @Published var titulo = ""
    @Published var descripcion = ""
    
    // Propiedades para la foto
    @Published var fotoSeleccionada: PhotosPickerItem? {
        didSet { Task { await cargarImagen(from: fotoSeleccionada) } }
    }
    @Published var datosDeImagen: Data?
    
    // Propiedades para los horarios
    @Published var horariosState: [HorarioDiaState] = Array(repeating: HorarioDiaState(), count: 7)
    let diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    // Estado de la UI
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveCompleted = false

    /// Guarda la nueva instalación en Firebase
    func guardarInstalacion() async {
        isSaving = true
        errorMessage = nil
        
        guard !titulo.isEmpty else {
            errorMessage = "El título no puede estar vacío."
            isSaving = false
            return
        }
        
        guard let imageData = datosDeImagen else {
            errorMessage = "Por favor, selecciona una imagen."
            isSaving = false
            return
        }
        
        do {
            let urlDeImagen = try await StorageManager.shared.subirImagen(imageData: imageData, carpeta: "instalaciones")
            
            // Convertir el estado de los horarios al formato del modelo de datos
            let horariosParaGuardar = construirDiccionarioHorarios()
            
            let nuevaInstalacion = Instalacion(
                titulo: titulo,
                descripcion: descripcion,
                imagenUrl: urlDeImagen.absoluteString,
                timestamp: Int64(Date().timeIntervalSince1970 * 1000),
                horarios: horariosParaGuardar.isEmpty ? nil : horariosParaGuardar
            )
            
            try await FirestoreManager.shared.añadirDocumento(codable: nuevaInstalacion, en: "Instalaciones")
            
            isSaving = false
            saveCompleted = true
            
        } catch {
            errorMessage = "Error al guardar la instalación: \(error.localizedDescription)"
            isSaving = false
        }
    }
    
    /// Construye el diccionario [String: Horario] para guardar en Firestore
    private func construirDiccionarioHorarios() -> [String: Instalacion.Horario] {
        var diccionario = [String: Instalacion.Horario]()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        for i in 0..<diasSemana.count {
            if horariosState[i].activo {
                let diaKey = diasSemana[i].lowercased().folding(options: .diacriticInsensitive, locale: .current)
                let aperturaStr = formatter.string(from: horariosState[i].apertura)
                let cierreStr = formatter.string(from: horariosState[i].cierre)
                diccionario[diaKey] = Instalacion.Horario(apertura: aperturaStr, cierre: cierreStr)
            }
        }
        return diccionario
    }
    
    private func cargarImagen(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            datosDeImagen = try await item.loadTransferable(type: Data.self)
        } catch {
            print("Error al cargar datos de la imagen: \(error)")
            errorMessage = "No se pudo cargar la imagen seleccionada."
        }
    }
}
