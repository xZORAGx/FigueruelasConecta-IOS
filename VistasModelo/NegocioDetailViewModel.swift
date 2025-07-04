import Foundation

@MainActor
class NegocioDetailViewModel: ObservableObject {
    @Published var contenido: [ContenidoNegocio] = []
    @Published var isLoading = false

    // ✅ Usa un String y un Bool
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false

    let negocio: Negocio

    init(negocio: Negocio) {
        self.negocio = negocio
    }

    func fetchContenido() async {
        guard let businessId = negocio.id else {
            self.errorMessage = "El ID del negocio no es válido."
            self.showAlert = true
            return
        }

        self.isLoading = true
        do {
            self.contenido = try await FirestoreManager.shared.fetchContent(for: businessId)
        } catch {
            self.errorMessage = "Error al cargar el contenido: \(error.localizedDescription)"
            self.showAlert = true
        }
        self.isLoading = false
    }
}
