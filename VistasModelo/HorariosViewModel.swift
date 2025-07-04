import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage // ✅ AÑADE ESTA LÍNEA

@MainActor
class HorariosViewModel: ObservableObject {

    // --- PROPIEDADES PUBLICADAS ---
    // (Estas no cambian)
    @Published var instalaciones: [Instalacion] = []
    @Published var autobuses: [Autobus] = []
    @Published var esAdmin: Bool = false
    @Published var seleccionDeVista: VistaSeleccionada = .instalaciones
    @Published var filtroBus: FiltroBus = .todos
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // --- ENUMS Y PROPIEDADES COMPUTADAS ---
    // (Tampoco cambian)
    enum VistaSeleccionada: String, CaseIterable {
        case instalaciones = "Instalaciones", autobuses = "Autobuses"
    }
    enum FiltroBus: String, CaseIterable {
        case todos = "Todos", ida = "Ida (Zaragoza)", vuelta = "Vuelta (Figueruelas)"
    }
    var autobusesFiltrados: [Autobus] {
        // ... (la lógica de filtrado no cambia)
        switch filtroBus {
        case .todos: return autobuses
        case .ida: return autobuses.filter { $0.tipoDireccion == .ida }
        case .vuelta: return autobuses.filter { $0.tipoDireccion == .vuelta }
        }
    }
    
    // --- REFERENCIAS A FIREBASE ---
    // (Igual que en tu DeportesViewModel)
    private let db = Firestore.firestore()
    private var puebloRef: DocumentReference {
        db.collection("pueblos").document("Figueruelas")
    }

    // --- INICIALIZADOR ---
    // (Ahora sigue el patrón de DeportesViewModel)
    init() {
        Task {
            await verificarSiEsAdmin()
            await cargarDatosIniciales()
        }
    }

    // MARK: - Lógica de Carga de Datos
    
    /// Comprueba si el usuario actual es Admin, igual que en DeportesViewModel.
    func verificarSiEsAdmin() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.esAdmin = false
            return
        }
        
        do {
            let document = try await puebloRef.collection("Usuarios").document(userId).getDocument()
            self.esAdmin = document.data()?["Tipo"] as? String == "Admin"
        } catch {
            self.esAdmin = false
            print("HorariosViewModel: No se pudo verificar el estado de administrador.")
        }
    }
    
    /// Carga los datos iniciales para ambas secciones.
    func cargarDatosIniciales() async {
        isLoading = true
        await cargarInstalaciones()
        await cargarAutobuses()
        isLoading = false
    }

    private func cargarInstalaciones() async {
        do {
            let snapshot = try await puebloRef.collection("Instalaciones").order(by: "timestamp", descending: true).getDocuments()
            self.instalaciones = snapshot.documents.compactMap { try? $0.data(as: Instalacion.self) }
        } catch {
            self.errorMessage = "Error al cargar instalaciones: \(error.localizedDescription)"
        }
    }

    private func cargarAutobuses() async {
        do {
            let snapshot = try await puebloRef.collection("Autobuses").getDocuments()
            self.autobuses = snapshot.documents.compactMap { try? $0.data(as: Autobus.self) }.sorted(by: { $0.nombreLinea < $1.nombreLinea })
        } catch {
            self.errorMessage = "Error al cargar autobuses: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Lógica de Eliminación (ahora asíncrona)

    func eliminarInstalacion(at offsets: IndexSet) {
        let itemsAEliminar = offsets.map { instalaciones[$0] }
        Task {
            for instalacion in itemsAEliminar {
                guard let id = instalacion.id else { continue }
                do {
                    // Borrar de Firestore
                    try await puebloRef.collection("Instalaciones").document(id).delete()
                    // Borrar imagen de Storage
                    let storageRef = Storage.storage().reference(forURL: instalacion.imagenUrl)
                    try? await storageRef.delete()
                } catch {
                    self.errorMessage = "Error al eliminar la instalación: \(instalacion.titulo)"
                }
            }
            await cargarInstalaciones() // Recargar la lista
        }
    }

    func eliminarAutobus(at offsets: IndexSet) {
        let itemsAEliminar = offsets.map { autobusesFiltrados[$0] }
        let idsAEliminar = itemsAEliminar.compactMap { $0.id }
        
        guard !idsAEliminar.isEmpty else { return }
        
        Task {
            let batch = db.batch()
            idsAEliminar.forEach { id in
                let docRef = puebloRef.collection("Autobuses").document(id)
                batch.deleteDocument(docRef)
            }
            do {
                try await batch.commit()
                await cargarAutobuses() // Recargar la lista
            } catch {
                self.errorMessage = "Error al eliminar horarios de autobús."
            }
        }
    }
}
