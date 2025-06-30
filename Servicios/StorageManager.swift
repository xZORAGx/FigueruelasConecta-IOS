//
//  StorageManager.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 30/6/25.
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
    }

    /// Sube una imagen a una carpeta específica en Firebase Storage.
    /// - Parameters:
    ///   - image: La imagen (UIImage) que se va a subir.
    ///   - carpeta: El nombre de la carpeta de destino (ej. "Noticias").
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
}
