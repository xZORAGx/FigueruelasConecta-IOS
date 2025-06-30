import Foundation
import Combine
import FirebaseFirestore


// Definimos un nombre de notificación personalizado para usar en toda la app.
extension Notification.Name {
    static let noticiaCreada = Notification.Name("NoticiaCreadaConExito")
}

@MainActor
class NoticiasViewModel: ObservableObject {
    
    @Published var noticias = [Noticia]()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let noticiasRef = Firestore.firestore().collection("pueblos/Figueruelas/Noticias")

    init() {
        // Se suscribe a la notificación 'noticiaCreada'. Cuando la recibe,
        // refresca la lista de noticias automáticamente.
        NotificationCenter.default.publisher(for: .noticiaCreada)
            .sink { [weak self] _ in
                print("Notificación 'noticiaCreada' recibida. Refrescando lista...")
                Task {
                    await self?.cargarNoticias()
                }
            }
            .store(in: &cancellables)
    }

    /// Carga la lista de noticias desde Firestore, ordenadas por fecha.
    func cargarNoticias() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let querySnapshot = try await noticiasRef
                                          .order(by: "timestamp", descending: true)
                                          .getDocuments()

            self.noticias = querySnapshot.documents.compactMap { document -> Noticia? in
                do {
                    return try document.data(as: Noticia.self)
                } catch {
                    print("Error al decodificar noticia \(document.documentID): \(error)")
                    return nil
                }
            }
        } catch {
            self.errorMessage = "No se pudieron cargar las noticias."
            print("Error en la consulta de noticias: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    /// Elimina una o más noticias de la lista y de Firebase.
    /// - Parameter offsets: El conjunto de índices de las noticias a eliminar, proporcionado por el `.onDelete` de SwiftUI.
    func eliminarNoticia(at offsets: IndexSet) {
        // Obtenemos las noticias que el usuario quiere borrar.
        let noticiasAEliminar = offsets.map { self.noticias[$0] }
        
        // Borramos las noticias de la lista local inmediatamente para una
        // respuesta visual instantánea en la UI.
        self.noticias.remove(atOffsets: offsets)
        
        // Ahora, procesamos el borrado en segundo plano en Firebase para cada noticia.
        for noticia in noticiasAEliminar {
            Task {
                do {
                    // 1. Nos aseguramos de que la noticia tiene un ID.
                    guard let documentId = noticia.id else {
                        print("Error: La noticia no tiene ID para ser eliminada.")
                        return
                    }
                    
                    // 2. Si tiene URL de imagen, la borramos de Storage.
                    if !noticia.imagenURL.isEmpty {
                        try await StorageManager.shared.eliminarImagen(from: noticia.imagenURL)
                        print("Imagen de Storage eliminada con éxito.")
                    }
                    
                    // 3. Borramos el documento de Firestore.
                    try await noticiasRef.document(documentId).delete()
                    print("Documento de Firestore eliminado con éxito.")
                    
                } catch {
                    // Si algo falla en el borrado de Firebase, lo notificamos en la consola.
                    print("Error al eliminar la noticia de Firebase: \(error.localizedDescription)")
                    // Opcional: Podríamos mostrar un error al usuario o recargar la lista
                    // para que la noticia que no se pudo borrar vuelva a aparecer.
                    // self.errorMessage = "No se pudo eliminar la noticia. Inténtalo de nuevo."
                }
            }
        }
    }
}
