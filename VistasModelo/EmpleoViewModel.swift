import Foundation
import SwiftUI
import PhotosUI

@MainActor
class EmpleoViewModel: ObservableObject {
    
    @Published var empleos: [Empleo] = []
    @Published var isLoading = false
    @Published var esAdmin = false
    
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    @Published var seleccionados = Set<String>()
    
    @Published var titulo: String = ""
    @Published var descripcion: String = ""
    @Published var imagenSeleccionada: PhotosPickerItem? {
        didSet { Task { await procesarImagen(item: imagenSeleccionada) } }
    }
    @Published var imagenData: Data?
    
    init() {
        Task {
            await verificarRolUsuario()
            await cargarEmpleos()
        }
    }
    
    func verificarRolUsuario() async {
        do {
            let usuario = try await AuthManager.shared.fetchCurrentUserFromFirestore()
            
            // ✅ LÍNEA DE DEPURACIÓN AÑADIDA
            print("🕵️‍♂️ [Empleo] Verificando rol. Usuario: \(usuario.correo), Tipo leído: '\(usuario.tipo)'")
            
            self.esAdmin = (usuario.tipo == "Admin" || usuario.tipo == "Programador")
        } catch {
            self.esAdmin = false
            print("No se pudo verificar el rol del usuario para Empleo: \(error.localizedDescription)")
        }
    }
    
    // ... el resto de funciones no cambian ...

    func cargarEmpleos() async {
        isLoading = true
        do {
            self.empleos = try await FirestoreManager.shared.fetchEmpleos()
        } catch {
            self.errorMessage = "Error al cargar las ofertas de empleo."
            self.showAlert = true
        }
        isLoading = false
    }
    
    func eliminarEmpleosSeleccionados() async {
        guard !seleccionados.isEmpty else { return }
        let idsParaBorrar = seleccionados
        let empleosAEliminar = empleos.filter { idsParaBorrar.contains($0.id ?? "") }
        
        isLoading = true
        for empleo in empleosAEliminar {
            guard let empleoId = empleo.id else { continue }
            do {
                if let url = empleo.imagenUrl, !url.isEmpty {
                    try await StorageManager.shared.deleteImageWithUrl(from: url)
                }
                try await FirestoreManager.shared.deleteEmpleo(empleoId: empleoId)
            } catch {
                self.errorMessage = "No se pudo eliminar '\(empleo.titulo)'."
                self.showAlert = true
                break
            }
        }
        self.seleccionados.removeAll()
        await cargarEmpleos()
    }

    func toggleSeleccion(para empleoId: String) {
        if seleccionados.contains(empleoId) {
            seleccionados.remove(empleoId)
        } else {
            seleccionados.insert(empleoId)
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
        await cargarEmpleos()
    }
    
    func limpiarFormulario() {
        titulo = ""
        descripcion = ""
        imagenSeleccionada = nil
        imagenData = nil
    }
}
