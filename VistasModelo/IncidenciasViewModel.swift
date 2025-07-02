import Foundation
import Combine

@MainActor
class IncidenciasViewModel: ObservableObject {
    // MARK: - Estado de la Vista
    @Published var incidencias: [Incidencia] = []
    @Published var incidenciasSeleccionadas = Set<String>()
    @Published var filtroSeleccionado: String = "Todas"
    @Published var isLoading = false
    @Published var errorMessage: String?

    // ✅ AQUÍ ESTÁ EL CAMBIO CON LAS NUEVAS OPCIONES
    let tiposDeFiltro = ["Todas", "Incidencia en el pueblo", "Recomendación de la app", "Mascota perdida", "Objeto perdido"]
    
    private let firestoreManager = FirestoreManager.shared
    private let storageManager = StorageManager.shared
    
    // MARK: - Propiedad Computada para Filtrar
    var incidenciasFiltradas: [Incidencia] {
        if filtroSeleccionado == "Todas" {
            return incidencias
        }
        return incidencias.filter { $0.tipo == filtroSeleccionado }
    }
    
    // MARK: - Acciones
    func fetchIncidencias() async {
        isLoading = true
        errorMessage = nil
        do {
            self.incidencias = try await firestoreManager.fetchCollection(from: .incidencias(pueblo: "Figueruelas"))
        } catch {
            self.errorMessage = "Error al cargar incidencias: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func toggleSeleccion(incidenciaId: String) {
        if incidenciasSeleccionadas.contains(incidenciaId) {
            incidenciasSeleccionadas.remove(incidenciaId)
        } else {
            incidenciasSeleccionadas.insert(incidenciaId)
        }
    }
    
    func eliminarIncidenciasSeleccionadas() async {
        isLoading = true
        let idsParaBorrar = incidenciasSeleccionadas
        
        for id in idsParaBorrar {
            guard let incidencia = incidencias.first(where: { $0.id == id }) else { continue }
            
            do {
                if let fotoUrl = incidencia.fotoUrl, !fotoUrl.isEmpty {
                    try await storageManager.deleteImage(fromURL: fotoUrl)
                }
                
                try await firestoreManager.deleteDocument(in: .incidencias(pueblo: "Figueruelas"), withId: id)
                
                incidencias.removeAll { $0.id == id }
                incidenciasSeleccionadas.remove(id)
                
            } catch {
                errorMessage = "Error al borrar la incidencia \(incidencia.titulo): \(error.localizedDescription)"
                isLoading = false
                return
            }
        }
        isLoading = false
    }
}
