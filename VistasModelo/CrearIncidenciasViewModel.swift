//
//  CrearIncidenciasViewModel.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import UIKit
import FirebaseFirestore // Necesario para el Timestamp

@MainActor
class CrearIncidenciaViewModel: ObservableObject {
    // MARK: - Propiedades del Formulario
    @Published var titulo = ""
    @Published var descripcion = ""
    @Published var tipoSeleccionado = "Incidencia en el pueblo"
    @Published var imagenSeleccionada: UIImage?
    
    // MARK: - Estado de la UI
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAlert = false
    @Published var didSuccessfullyUpload = false

    let tiposDeIncidencia = ["Incidencia en el pueblo", "Recomendación de la app", "Mascota perdida", "Objeto perdido"]
    
    private let authManager = AuthManager.shared
    private let storageManager = StorageManager.shared
    private let firestoreManager = FirestoreManager.shared
    
    func crearIncidencia() async {
        // 1. Validar los datos
        guard !titulo.isEmpty, !descripcion.isEmpty else {
            errorMessage = "El título y la descripción no pueden estar vacíos."
            showAlert = true
            return
        }
        guard let imagen = imagenSeleccionada else {
            errorMessage = "Debes seleccionar una imagen."
            showAlert = true
            return
        }
        guard let userEmail = authManager.currentUserEmail else {
            errorMessage = "Error de autenticación. Por favor, inicia sesión de nuevo."
            showAlert = true

            return
        }
        
        isLoading = true
        
        do {
            // 2. Subir la imagen a Storage
            let imageUrl = try await storageManager.uploadImage(image: imagen, folder: "incidencias")
            
            // 3. Preparar los datos para Firestore
            // Calculamos la fecha de expiración para 3 meses en el futuro (TTL)
            let tresMesesDesdeAhora = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
            let fechaExpiracion = Timestamp(date: tresMesesDesdeAhora)

            let incidenciaData: [String: Any] = [
                "Titulo": titulo,
                "Descripcion": descripcion,
                "tipo": tipoSeleccionado,
                "Correo": userEmail,
                "fotoUrl": imageUrl.absoluteString,
                "fechaExpiracion": fechaExpiracion
            ]
            
            // 4. Guardar el documento en Firestore
            try await firestoreManager.addDocument(data: incidenciaData, to: .incidencias(pueblo: "Figueruelas"))
            
            // 5. Éxito
            didSuccessfullyUpload = true
            
        } catch {
            errorMessage = "Se produjo un error: \(error.localizedDescription)"
            showAlert = true
        }
        
        isLoading = false
    }
}
