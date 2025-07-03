import Foundation
import SwiftUI
import PhotosUI

@MainActor
class EmpleoViewModel: ObservableObject {
    
    @Published var empleos: [Empleo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var esAdmin = false
    
    // Un conjunto para guardar los IDs de los empleos seleccionados.
    @Published var seleccionados = Set<String>()
    
    // Propiedades para la vista de creación
    @Published var titulo: String = ""
    @Published var descripcion: String = ""
    @Published var imagenSeleccionada: PhotosPickerItem? {
        didSet {
            Task {
                await procesarImagen(item: imagenSeleccionada)
            }
        }
    }
    @Published var imagenData: Data?
    
    init() {
        cargarEmpleos()
    }
    
    // Nueva función para marcar/desmarcar un empleo.
    func toggleSeleccion(para empleoId: String) {
        if seleccionados.contains(empleoId) {
            seleccionados.remove(empleoId)
        } else {
            seleccionados.insert(empleoId)
        }
    }
    
    func eliminarEmpleosSeleccionados() {
        // Ahora usamos el conjunto 'seleccionados'.
        guard !seleccionados.isEmpty else { return }
        
        let idsParaBorrar = seleccionados
        
        isLoading = true
        
        Task {
            // Buscamos los objetos Empleo completos que coincidan con los IDs
            let empleosAEliminar = empleos.filter { idsParaBorrar.contains($0.id ?? "") }

            for empleo in empleosAEliminar {
                guard let empleoId = empleo.id else { continue }
                
                do {
                    if let url = empleo.imagenUrl, !url.isEmpty {
                        try await StorageManager.shared.deleteImageWithUrl(from: url)
                    }
                    try await FirestoreManager.shared.deleteEmpleo(empleoId: empleoId)
                } catch {
                    self.errorMessage = "No se pudo eliminar '\(empleo.titulo)': \(error.localizedDescription)"
                    break
                }
            }
            
            // Limpiamos la selección y recargamos
            self.seleccionados.removeAll()
            cargarEmpleos()
        }
    }

    func cargarEmpleos() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                self.empleos = try await FirestoreManager.shared.fetchEmpleos()
            } catch {
                self.errorMessage = "Error al cargar las ofertas de empleo: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func procesarImagen(item: PhotosPickerItem?) async {
        guard let item = item else {
            self.imagenData = nil
            return
        }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.imagenData = data
        }
    }
    
    func guardarEmpleo() async throws {
        guard !titulo.isEmpty, !descripcion.isEmpty else {
            throw NSError(domain: "Validacion", code: 0, userInfo: [NSLocalizedDescriptionKey: "El título y la descripción son obligatorios."])
        }
        
        isLoading = true
        var imageUrl: String? = nil
        
        if let data = imagenData {
            let path = "empleos/\(UUID().uuidString).jpg"
            let url = try await StorageManager.shared.uploadImageData(data: data, path: path)
            imageUrl = url.absoluteString
        }
        
        try await FirestoreManager.shared.createEmpleo(titulo: titulo, descripcion: descripcion, imagenUrl: imageUrl)
        
        isLoading = false
        limpiarFormulario()
        cargarEmpleos()
    }
    
    func limpiarFormulario() {
        titulo = ""
        descripcion = ""
        imagenSeleccionada = nil
        imagenData = nil
    }
}
