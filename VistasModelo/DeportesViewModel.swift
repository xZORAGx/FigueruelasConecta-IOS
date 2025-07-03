import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

enum SeccionDeportes {
    case partidos
    case actividades
}

@MainActor
class DeportesViewModel: ObservableObject {

    @Published var seccionSeleccionada: SeccionDeportes = .partidos
    @Published var deportes: [Deporte] = []
    @Published var partidos: [Partido] = []
    @Published var actividades: [Actividad] = []
    @Published var deporteSeleccionado: Deporte?
    @Published var esAdmin: Bool = false
    @Published var modoEdicionPartidos: Bool = false
    @Published var seleccionPartidos = Set<Partido>()
    @Published var seleccionActividades = Set<Actividad>()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var cancellables = Set<AnyCancellable>()
    
    private var puebloRef: DocumentReference {
        db.collection("pueblos").document("Figueruelas")
    }

    init() {
        Task {
            await verificarSiEsAdmin()
            await cargarDeportes()
        }
        
        $seccionSeleccionada
            .sink { [weak self] seccion in
                Task {
                    await self?.manejarCambioDeSeccion(seccion)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Lógica de Carga de Datos
    
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
            self.errorMessage = "No se pudo verificar el estado de administrador."
        }
    }

    func cargarDeportes() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            let snapshot = try await puebloRef.collection("Deportes").getDocuments()
            self.deportes = snapshot.documents.compactMap { try? $0.data(as: Deporte.self) }
            
            if let primerDeporte = self.deportes.first {
                self.deporteSeleccionado = primerDeporte
                await filtrarPartidosPorDeporte(primerDeporte)
            }
        } catch {
            self.errorMessage = "Error al cargar los deportes: \(error.localizedDescription)"
        }
    }
    
    func seleccionarDeporte(_ deporte: Deporte) async {
        self.deporteSeleccionado = deporte
        if seccionSeleccionada == .partidos {
            await filtrarPartidosPorDeporte(deporte)
        }
    }

    func manejarCambioDeSeccion(_ seccion: SeccionDeportes) async {
        modoEdicionPartidos = false
        seleccionPartidos.removeAll()
        seleccionActividades.removeAll()
        
        switch seccion {
        case .partidos:
            if let deporte = deporteSeleccionado {
                await filtrarPartidosPorDeporte(deporte)
            } else {
                self.partidos = []
            }
        case .actividades:
            await cargarActividades()
        }
    }
    
    private func filtrarPartidosPorDeporte(_ deporte: Deporte) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            let snapshot = try await puebloRef.collection("Partidos").whereField("deporte", isEqualTo: deporte.nombre).getDocuments()
            self.partidos = snapshot.documents.compactMap { try? $0.data(as: Partido.self) }
        } catch {
            self.errorMessage = "Error al cargar partidos: \(error.localizedDescription)"
        }
    }
    
    private func cargarActividades() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            let snapshot = try await puebloRef.collection("Actividades").getDocuments()
            self.actividades = snapshot.documents.compactMap { try? $0.data(as: Actividad.self) }
        } catch {
            self.errorMessage = "Error al cargar actividades: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Lógica de Admin
    
    func toggleModoEdicionPartidos() {
        modoEdicionPartidos.toggle()
        if !modoEdicionPartidos {
            seleccionPartidos.removeAll()
        }
    }


    
    func borrarActividadesSeleccionadas() async {
        let itemsABorrar = seleccionActividades
        
        let batch = db.batch()
        itemsABorrar.forEach { actividad in
            if let id = actividad.id {
                let docRef = puebloRef.collection("Actividades").document(id)
                batch.deleteDocument(docRef)
            }
        }
        
        do {
            try await batch.commit()
            self.actividades.removeAll { self.seleccionActividades.contains($0) }
            
            for actividad in itemsABorrar {
                if let urlString = actividad.imageUrl, !urlString.isEmpty {
                    let storageRef = storage.reference(forURL: urlString)
                    try? await storageRef.delete()
                }
            }
            self.seleccionActividades.removeAll()
            
        } catch {
            self.errorMessage = "Error al borrar actividades: \(error.localizedDescription)"
        }
    }
    
    func guardarResultadosPartidos() async {
        isLoading = true
        do {
            try await FirestoreManager.shared.actualizarResultadosPartidos(partidos: self.partidos)
            self.toggleModoEdicionPartidos()
        } catch {
            self.errorMessage = "Error al guardar los resultados: \(error.localizedDescription)"
        }
        isLoading = false
    }
    func borrarPartidosSeleccionados() async {
        // 1. Obtenemos los IDs de los partidos seleccionados
        let idsParaBorrar = seleccionPartidos.compactMap { $0.id }
        
        guard !idsParaBorrar.isEmpty else { return }
        
        isLoading = true
        do {
            // 2. Llamamos al manager para que borre los documentos
            try await FirestoreManager.shared.borrarDocumentos(ids: idsParaBorrar, en: .partidos(pueblo: "Figueruelas"))
            
            // 3. Si todo va bien, actualizamos la UI localmente
            self.partidos.removeAll { seleccionPartidos.contains($0) }
            self.seleccionPartidos.removeAll()
            
        } catch {
            self.errorMessage = "Error al borrar los partidos: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
