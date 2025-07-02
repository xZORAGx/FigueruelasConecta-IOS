import Foundation
import UIKit
import FirebaseFirestore
import UniformTypeIdentifiers // Para obtener el tipo de archivo

@MainActor
class SubirCelebracionViewModel: ObservableObject {
    @Published var titulo = ""
    @Published var archivoURL: URL?
    @Published var nombreArchivo: String?
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var errorMessage: String?
    @Published var didSuccessfullyUpload = false
    
    private let storageManager = StorageManager.shared
    private let firestoreManager = FirestoreManager.shared
    
    func subirCelebracion() async {
        guard !titulo.isEmpty else {
            errorMessage = "El título no puede estar vacío."; showAlert = true; return
        }
        guard let localURL = archivoURL else {
            errorMessage = "Debes seleccionar un archivo."; showAlert = true; return
        }
        
        isLoading = true
        
        let accessGranted = localURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                localURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            guard accessGranted else {
                throw NSError(domain: "AppError", code: 100, userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener permiso para acceder al archivo."])
            }
            
            // Esta línea ahora funcionará porque la extensión existe
            guard let fileMimeType = localURL.mimeType, let fileExtension = getFileExtension(from: fileMimeType) else {
                throw NSError(domain: "AppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo determinar el tipo de archivo."])
            }
            
            let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            let sanitizedTitle = titulo.replacingOccurrences(of: "[^a-zA-Z0-9.-]", with: "_", options: .regularExpression)
            let fileNameInStorage = "\(sanitizedTitle)_\(timestamp).\(fileExtension)"
            let fullPath = "celebraciones/Figueruelas/\(fileNameInStorage)"

            let fileData = try Data(contentsOf: localURL)

            let (downloadURL, storagePath) = try await storageManager.uploadData(data: fileData, fullPath: fullPath)
            
            let tresMesesDesdeAhora = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
            let fechaExpiracion = Timestamp(date: tresMesesDesdeAhora)

            let data: [String: Any] = [
                "titulo": titulo,
                "pdfUrl": downloadURL.absoluteString,
                "storagePath": storagePath,
                "mimeType": fileMimeType,
                "timestamp": Double(timestamp),
                "fechaExpiracion": fechaExpiracion
            ]
            
            try await firestoreManager.addDocument(data: data, to: .celebraciones(pueblo: "Figueruelas"))
            
            didSuccessfullyUpload = true
            
        } catch {
            errorMessage = "Se produjo un error: \(error.localizedDescription)"
            showAlert = true
        }
        
        isLoading = false
    }

    private func getFileExtension(from mimeType: String) -> String? {
        switch mimeType {
        case "image/jpeg": return "jpg"
        case "image/png": return "png"
        case "application/pdf": return "pdf"
        default: return UTType(mimeType: mimeType)?.preferredFilenameExtension
        }
    }
}

// --- BLOQUE DE CÓDIGO AÑADIDO ---
// Pequeña extensión a URL para obtener fácilmente el MimeType
extension URL {
    var mimeType: String? {
        UTType(filenameExtension: self.pathExtension)?.preferredMIMEType
    }
}
