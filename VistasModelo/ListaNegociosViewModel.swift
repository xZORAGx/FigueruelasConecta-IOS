import Foundation

@MainActor
class ListaNegociosViewModel: ObservableObject {
    @Published var negocios: [Negocio] = []
    @Published var isLoading = false
    
    // ✅ Cambiado a un String simple y un Bool
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false

    @Published var isSelectionActive = false
    @Published var selectedBusinessIDs = Set<String>()

    func fetchNegocios() async {
        isLoading = true
        do {
            self.negocios = try await FirestoreManager.shared.fetchBusinesses()
        } catch {
            self.errorMessage = "Error al cargar los negocios: \(error.localizedDescription)"
            self.showAlert = true
        }
        isLoading = false
    }
    
    func toggleSelection(for businessID: String) {
        if selectedBusinessIDs.contains(businessID) {
            selectedBusinessIDs.remove(businessID)
        } else {
            selectedBusinessIDs.insert(businessID)
        }
    }
    
    func deleteSelectedBusinesses() async {
        isLoading = true
        let businessesToDelete = negocios.filter { selectedBusinessIDs.contains($0.id ?? "") }
        
        for business in businessesToDelete {
            do {
                try await FirestoreManager.shared.deleteBusiness(business: business)
                if !business.logoUrl.isEmpty {
                    try await StorageManager.shared.deleteBusinessImage(fromURL: business.logoUrl)
                }
            } catch {
                self.errorMessage = "Fallo al borrar '\(business.titulo)': \(error.localizedDescription)"
                self.showAlert = true
            }
        }
        
        selectedBusinessIDs.removeAll()
        isSelectionActive = false
        await fetchNegocios()
    }
}
