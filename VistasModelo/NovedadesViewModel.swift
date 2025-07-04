import Foundation

@MainActor
class NovedadesViewModel: ObservableObject {
    @Published var novedades: [ContenidoNegocio] = []
    @Published var isLoading = false
    
    // ✅ Usa un String y un Bool
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false

    func fetchNovedades() async {
        isLoading = true
        do {
            self.novedades = try await FirestoreManager.shared.fetchLatestNews()
        } catch {
            self.errorMessage = "Error al cargar las novedades: \(error.localizedDescription)"
            self.showAlert = true
        }
        isLoading = false
    }
}
