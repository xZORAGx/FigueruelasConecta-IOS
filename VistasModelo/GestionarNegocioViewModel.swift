//
//  GestionarNegocioViewModel.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 4/7/25.
//

import Foundation
import UIKit // Necesitamos UIKit para manejar la imagen (UIImage)

@MainActor
class GestionarNegocioViewModel: ObservableObject {
    @Published var titulo = ""
    @Published var descripcion = ""
    @Published var imagen: UIImage?
    
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    private let negocioId: String
    private var nombreDelNegocio: String = ""
    private var logoDelNegocioUrl: String = ""

    init(negocioId: String) {
        self.negocioId = negocioId
        Task {
            await fetchBusinessDetails()
        }
    }

    // Obtiene los datos del negocio para poder "denormalizarlos" en la publicación
    private func fetchBusinessDetails() async {
        do {
            // Suponemos que tienes una función para obtener un solo negocio por ID.
            // Si no, la podemos crear. Por ahora, asumimos que existe.
            let negocios = try await FirestoreManager.shared.fetchBusinesses()
            if let miNegocio = negocios.first(where: { $0.id == self.negocioId }) {
                self.nombreDelNegocio = miNegocio.titulo
                self.logoDelNegocioUrl = miNegocio.logoUrl
            }
        } catch {
            print("Error cargando detalles del negocio: \(error.localizedDescription)")
        }
    }
    
    func publicarContenido() async -> Bool {
        guard !titulo.isEmpty else {
            self.errorMessage = "El título no puede estar vacío."
            self.showAlert = true
            return false
        }
        
        isLoading = true
        var imagenUrlParaGuardar: String?
        
        do {
            // 1. Subir la imagen a Storage si el usuario ha seleccionado una
            if let imagen = self.imagen {
                let url = try await StorageManager.shared.uploadBusinessImage(image: imagen, folder: "negociosContenido")
                imagenUrlParaGuardar = url.absoluteString
            }
            
            // 2. Crear el objeto ContenidoNegocio
            let nuevoContenido = ContenidoNegocio(
                titulo: self.titulo,
                descripcion: self.descripcion,
                imagenUrl: imagenUrlParaGuardar,
                timestamp: Date().timeIntervalSince1970 * 1000, // Usamos el timestamp como antes
                nombreNegocio: self.nombreDelNegocio,
                logoNegocioUrl: self.logoDelNegocioUrl
            )
            
            // 3. Guardar el contenido en Firestore
            try await FirestoreManager.shared.postBusinessContent(for: self.negocioId, content: nuevoContenido)
            
            isLoading = false
            return true // Éxito
            
        } catch {
            self.errorMessage = "Error al publicar: \(error.localizedDescription)"
            self.showAlert = true
            self.isLoading = false
            return false // Fracaso
        }
    }
}
