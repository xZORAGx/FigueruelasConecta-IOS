//
//  StorageManager.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 30/6/25.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageManager {
    
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    enum StorageError: Error {
        case failedToConvertToJPEG
        case failedToGetDownloadURL
        // --- AÑADIDO PARA LA NUEVA FUNCIÓN ---
        case failedToCompressImage
        case invalidURL
    }

    /// Sube una imagen a una carpeta específica en Firebase Storage.
    /// - Parameters:
    ///   - image: La imagen (UIImage) que se va a subir.
    ///   - carpeta: El nombre de la carpeta de destino (ej. "Noticias").
    /// - Returns: La URL de descarga de la imagen subida.
    func subirImagen(_ image: UIImage, aCarpeta carpeta: String) async throws -> URL {
        // Generamos un nombre de archivo único usando la fecha y hora.
        let nombreArchivo = "\(Date().timeIntervalSince1970).jpg"
        let storageRef = storage.child(carpeta).child(nombreArchivo)
        
        // Comprimimos la imagen a formato JPEG. 0.8 es un buen balance de calidad/tamaño.
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.failedToConvertToJPEG
        }
        
        // Subimos los datos a Firebase Storage.
        _ = try await storageRef.putDataAsync(data)
        
        // Una vez subida, obtenemos la URL de descarga.
        do {
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL
        } catch {
            throw StorageError.failedToGetDownloadURL
        }
    }
    func eliminarImagen(from urlString: String) async throws {
        // Obtenemos la referencia al archivo a partir de su URL.
        let storageRef = Storage.storage().reference(forURL: urlString)
        // Intentamos borrar el archivo.
        try await storageRef.delete()
    }
    func deleteImage(fromURL urlString: String) async throws {
        // Obtenemos la referencia de Storage a partir de la URL.
        let storageRef = Storage.storage().reference(forURL: urlString)
        // Intentamos borrar el fichero. Lanza un error si falla.
        try await storageRef.delete()
    }
    func uploadImage(image: UIImage, folder: String) async throws -> URL {
        // Generamos un nombre de fichero único.
        let fileName = UUID().uuidString + ".jpg"
        let storageReference = Storage.storage().reference().child(folder).child(fileName)
        
        // Comprimimos la imagen para que no ocupe tanto.
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StorageManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a formato JPEG."])
        }
        
        // Subimos los datos de la imagen.
        let _ = try await storageReference.putDataAsync(imageData)
        
        // Obtenemos y devolvemos la URL de descarga.
        let downloadURL = try await storageReference.downloadURL()
        return downloadURL
    }
    func uploadFile(from localURL: URL, folder: String) async throws -> (downloadURL: URL, storagePath: String, mimeType: String) {
        
        // Aseguramos que tenemos acceso al fichero
        guard localURL.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "StorageManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo acceder al archivo."])
        }
        
        // Leemos los datos del fichero
        let fileData = try Data(contentsOf: localURL)
        // Dejamos de acceder al fichero
        localURL.stopAccessingSecurityScopedResource()
        
        let fileName = localURL.lastPathComponent
    
        let storageReference = storage.child(folder).child(fileName)
        
        // Subimos los datos y obtenemos los metadatos
        let metadata = try await storageReference.putDataAsync(fileData)
        
        // Obtenemos la URL de descarga
        let downloadURL = try await storageReference.downloadURL()
        
        // Obtenemos el tipo MIME y la ruta de Storage
        let mimeType = metadata.contentType ?? "application/octet-stream"
        let storagePath = metadata.path ?? ""
        
        return (downloadURL, storagePath, mimeType)
    }
    func uploadData(data: Data, fullPath: String) async throws -> (downloadURL: URL, storagePath: String) {
        let storageReference = storage.child(fullPath)
        
        let metadata = try await storageReference.putDataAsync(data)
        let downloadURL = try await storageReference.downloadURL()
        
        return (downloadURL, metadata.path ?? "")
    }

    // MARK: - Eliminación de Archivos
    
    /// Elimina un archivo de Storage a partir de su URL de descarga.
    /// - Parameter urlString: La URL completa del archivo a eliminar.
    func eliminarArchivo(fromURL urlString: String) async throws {
        // Obtenemos la referencia al archivo a partir de su URL.
        let storageRef = Storage.storage().reference(forURL: urlString)
        
        // Intentamos borrar el archivo.
        try await storageRef.delete()
    }
    // MARK: - FUNCIONES PARA EMPLEO

    /// Sube datos de imagen (`Data`) a una ruta específica en Storage.
    func uploadImageData(data: Data, path: String) async throws -> URL {
        let storageRef = storage.child(path)
        _ = try await storageRef.putDataAsync(data)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL
    }

    /// Elimina una imagen de Storage a partir de su URL de descarga.
    func deleteImageWithUrl(from url: String) async throws {
        let storageRef = Storage.storage().reference(forURL: url)
        try await storageRef.delete()
    }
    
    // MARK: - DEPORTES (AÑADIDO)

    /// Sube un fichero (imagen o PDF) para una actividad. Si es imagen, la comprime.
    /// - Parameters:
    ///   - fileUrl: La URL local del fichero seleccionado por el usuario.
    ///   - path: La ruta de la carpeta en Storage donde se guardará (ej: "actividades/Figueruelas").
    /// - Returns: La URL de descarga pública del fichero subido.
    func uploadFileForActivity(from fileUrl: URL, path: String) async throws -> URL {
        // Asegurarnos de que podemos acceder al fichero de forma segura
        guard fileUrl.startAccessingSecurityScopedResource() else {
            throw StorageError.invalidURL
        }
        
        // Generamos un nombre de archivo único para evitar sobreescrituras
        let fileName = "\(UUID().uuidString).\(fileUrl.pathExtension)"
        let fileRef = storage.child(path).child(fileName)
        
        let data: Data

        // Comprobamos si es una imagen para comprimirla
        if let image = UIImage(contentsOfFile: fileUrl.path) {
            // Comprimimos la imagen a JPEG con una calidad del 80%
            guard let compressedData = image.jpegData(compressionQuality: 0.8) else {
                fileUrl.stopAccessingSecurityScopedResource()
                throw StorageError.failedToCompressImage
            }
            data = compressedData
        } else {
            // Si no es una imagen (ej. PDF), leemos los datos directamente
            data = try Data(contentsOf: fileUrl)
        }

        // Dejamos de acceder al recurso original
        fileUrl.stopAccessingSecurityScopedResource()
        
        // Subimos los datos a Firebase Storage
        _ = try await fileRef.putDataAsync(data)
        
        // Obtenemos y devolvemos la URL de descarga
        let downloadURL = try await fileRef.downloadURL()
        return downloadURL
    }
}
