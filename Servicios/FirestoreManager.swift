import Foundation
import FirebaseFirestore

enum FirestoreCollection {
    case noticias(pueblo: String)
    case usuarios(pueblo: String)
    case incidencias(pueblo: String)
    case celebraciones(pueblo: String)
    case empleo(pueblo: String)
    // --- AÑADIDO PARA DEPORTES ---
    case deportes(pueblo: String)
    case partidos(pueblo: String)
    case actividades(pueblo: String)
    case negocios(pueblo: String) // <-- AÑADIDO

    var path: String {
        switch self {
        case .noticias(let pueblo):
            return "pueblos/\(pueblo)/Noticias"
        case .usuarios(let pueblo):
            return "pueblos/\(pueblo)/Usuarios"
        case .incidencias(let pueblo):
            return "pueblos/\(pueblo)/Incidencias"
        case .celebraciones(let pueblo):
            return "pueblos/\(pueblo)/Celebraciones"
        case .empleo(let pueblo):
            return "pueblos/\(pueblo)/Empleo"
        // --- AÑADIDO PARA DEPORTES ---
        case .deportes(let pueblo):
            return "pueblos/\(pueblo)/Deportes"
        case .partidos(let pueblo):
            return "pueblos/\(pueblo)/Partidos"
        case .actividades(let pueblo):
            return "pueblos/\(pueblo)/Actividades"
        case .negocios(let pueblo): // <-- AÑADIDO
            return "pueblos/\(pueblo)/Negocios"
        }
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    private init() {}
    private let puebloID = "Figueruelas"
    
    // Tu función de noticias
    func fetchNoticias() async throws -> [Noticia] {
        let pueblo = "Figueruelas"
        let collectionPath = FirestoreCollection.noticias(pueblo: pueblo).path
        let querySnapshot = try await db.collection(collectionPath)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return querySnapshot.documents.compactMap { try? $0.data(as: Noticia.self) }
    }
    
    // MARK: - GESTIÓN DE USUARIOS (async/await)
    func listenForUsers() -> AsyncThrowingStream<[Usuario], Error> {
        let pueblo = "Figueruelas"
        let path = FirestoreCollection.usuarios(pueblo: pueblo).path
        
        return AsyncThrowingStream { continuation in
            let listener = db.collection(path).addSnapshotListener { querySnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    continuation.yield([])
                    return
                }
                let usuarios = documents.compactMap { try? $0.data(as: Usuario.self) }
                continuation.yield(usuarios)
            }
            continuation.onTermination = { @Sendable _ in listener.remove() }
        }
    }
    
    func updateDocument(in collection: FirestoreCollection, withId id: String, data: [String: Any]) async throws {
        try await db.collection(collection.path).document(id).updateData(data)
    }
    
    func deleteDocument(in collection: FirestoreCollection, withId id: String) async throws {
        try await db.collection(collection.path).document(id).delete()
    }
    
    func fetchCollection<T: Decodable>(from collection: FirestoreCollection) async throws -> [T] {
        let snapshot = try await db.collection(collection.path).getDocuments()
        
        let result = snapshot.documents.compactMap { doc -> T? in
            do {
                return try doc.data(as: T.self)
            } catch {
                print("Error decodificando documento \(doc.documentID): \(error)")
                return nil
            }
        }
        return result
    }
    
    func addDocument(data: [String: Any], to collection: FirestoreCollection) async throws {
        try await db.collection(collection.path).addDocument(data: data)
    }
    
    func fetchCelebraciones() async throws -> [Celebracion] {
        let collectionPath = FirestoreCollection.celebraciones(pueblo: "Figueruelas").path
        
        let querySnapshot = try await db.collection(collectionPath)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        let celebraciones = querySnapshot.documents.compactMap { document -> Celebracion? in
            return try? document.data(as: Celebracion.self)
        }
        
        return celebraciones
    }
    
    // MARK: - EMPLEO
    private var empleoRef: CollectionReference {
        return db.collection(FirestoreCollection.empleo(pueblo: "Figueruelas").path)
    }
    
    func fetchEmpleos() async throws -> [Empleo] {
        let querySnapshot = try await empleoRef
            .order(by: "fechaCreacion", descending: true)
            .getDocuments()
        
        let empleos = querySnapshot.documents.compactMap { document -> Empleo? in
            try? document.data(as: Empleo.self)
        }
        
        return empleos
    }
    
    func createEmpleo(titulo: String, descripcion: String, imagenUrl: String?) async throws {
        let calendar = Calendar.current
        guard let tresMesesDespues = calendar.date(byAdding: .month, value: 3, to: Date()) else {
            throw NSError(domain: "DateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        let expiracionTimestamp = Timestamp(date: tresMesesDespues)
        
        let nuevoEmpleo = Empleo(
            titulo: titulo,
            descripcion: descripcion,
            imagenUrl: imagenUrl,
            fechaCreacion: nil, // Firestore lo rellena con @ServerTimestamp
            fechaExpiracion: expiracionTimestamp
        )
        
        try empleoRef.document().setData(from: nuevoEmpleo)
    }
    
    func deleteEmpleo(empleoId: String) async throws {
        try await empleoRef.document(empleoId).delete()
    }
    
    // MARK: - DEPORTES (AÑADIDO)
    
    /// Crea un nuevo documento en la colección de Deportes.
    /// - Throws: Lanza un error si la escritura en Firestore falla.
    func crearDeporte(nombre: String, emoji: String, filtro: String) async throws {
        let nuevoDeporte: [String: Any] = [
            "nombre": nombre,
            "emoji": emoji,
            "filtro": filtro
        ]
        
        // Usamos nuestro enum para mantener la consistencia
        let collection = FirestoreCollection.deportes(pueblo: "Figueruelas")
        try await db.collection(collection.path).addDocument(data: nuevoDeporte)
    }
    func crearPartido(equipo1: String, equipo2: String, fecha: Date, deporte: String, categoria: String, diaSemana: String) async throws {
        // Calculamos la fecha de expiración para autolimpieza (1 mes desde la fecha del partido)
        guard let fechaExpiracion = Calendar.current.date(byAdding: .month, value: 1, to: fecha) else {
            throw NSError(domain: "DateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        
        // Formateamos la fecha a un string legible "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let fechaString = dateFormatter.string(from: fecha)
        
        let nuevoPartido = Partido(
            equipo1: equipo1,
            equipo2: equipo2,
            fecha: fechaString,
            deporte: deporte,
            categoria: categoria,
            diaSemana: diaSemana,
            resultado: "0 - 0", // Resultado inicial por defecto
            fechaExpiracion: Timestamp(date: fechaExpiracion)
        )
        
        let collection = FirestoreCollection.partidos(pueblo: "Figueruelas")
        // Usamos setData(from:) que codifica nuestro objeto Partido automáticamente
        try db.collection(collection.path).document().setData(from: nuevoPartido)
    }
    func crearActividad(titulo: String, downloadUrl: URL) async throws {
        guard let fechaExpiracion = Calendar.current.date(byAdding: .month, value: 3, to: Date()) else {
            throw NSError(domain: "DateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        
        let nuevaActividad = Actividad(
            titulo: titulo,
            imageUrl: downloadUrl.absoluteString,
            fechaExpiracion: Timestamp(date: fechaExpiracion)
        )
        
        let collection = FirestoreCollection.actividades(pueblo: "Figueruelas")
        try db.collection(collection.path).document().setData(from: nuevaActividad)
    }
    func actualizarResultadosPartidos(partidos: [Partido]) async throws {
        let batch = db.batch()
        let collection = FirestoreCollection.partidos(pueblo: "Figueruelas")
        
        print("MANAGER: Creando una operación por lotes (batch write).")
        
        for partido in partidos {
            guard let partidoId = partido.id else {
                print("MANAGER AVISO: Se ha omitido un partido porque no tiene ID.")
                continue
            }
            let docRef = db.collection(collection.path).document(partidoId)
            print("  - MANAGER: Añadiendo al lote -> Documento '\(partidoId)' actualizar resultado a '\(partido.resultado)'")
            batch.updateData(["resultado": partido.resultado], forDocument: docRef)
        }
        
        print("MANAGER: Enviando el lote de actualizaciones a Firebase...")
        try await batch.commit()
        print("MANAGER: El lote se ha completado en Firebase con éxito.")
    }
    func borrarDocumentos(ids: [String], en coleccion: FirestoreCollection) async throws {
        guard !ids.isEmpty else { return } // No hace nada si no hay IDs
        
        let batch = db.batch()
        let collectionPath = coleccion.path
        
        for id in ids {
            let docRef = db.collection(collectionPath).document(id)
            batch.deleteDocument(docRef)
        }
        
        try await batch.commit()
    }
    
    func obtenerInstalaciones(completion: @escaping (Result<[Instalacion], Error>) -> Void) {
        let docRef = db.collection("pueblos").document(puebloID).collection("Instalaciones")
        
        docRef.order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error al obtener instalaciones: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([])) // Devuelve un array vacío si no hay documentos
                return
            }
            
            let instalaciones = documents.compactMap { document -> Instalacion? in
                try? document.data(as: Instalacion.self)
            }
            
            completion(.success(instalaciones))
        }
    }
    
    
    /// Obtiene todos los documentos de la colección "Autobuses" y los convierte a objetos `Autobus`.
    func obtenerAutobuses(completion: @escaping (Result<[Autobus], Error>) -> Void) {
        let docRef = db.collection("pueblos").document(puebloID).collection("Autobuses")
        
        // NOTA: En Android ordenabas por direccion y luego por nombre.
        // Aquí podemos dejar que el ViewModel se encargue del orden si es necesario.
        docRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error al obtener autobuses: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let autobuses = documents.compactMap { document -> Autobus? in
                try? document.data(as: Autobus.self)
            }
            
            completion(.success(autobuses))
        }
    }
    
    
    /// Elimina un único documento de una colección específica.
    /// Reutilizable para Instalaciones, Noticias, etc.
    func eliminarDocumento(id: String, en coleccion: String, completion: @escaping (Error?) -> Void) {
        db.collection("pueblos").document(puebloID).collection(coleccion).document(id).delete { error in
            completion(error)
        }
    }
    
    
    /// Elimina múltiples documentos de la colección "Autobuses" usando un WriteBatch para mayor eficiencia.
    /// Es el equivalente Swift a tu `WriteBatch` de Android.
    func eliminarAutobuses(conIds ids: [String], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        
        for id in ids {
            let docRef = db.collection("pueblos").document(puebloID).collection("Autobuses").document(id)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { error in
            completion(error)
        }
    }
    // Dentro de la clase FirestoreManager
    func añadirDocumento<T: Codable>(codable: T, en coleccion: String) async throws {
        // Usamos el encoder de Firestore para convertir nuestro objeto Swift a un diccionario
        let data = try Firestore.Encoder().encode(codable)
        // El método addDocument creará un documento con un ID automático
        try await db.collection("pueblos").document(puebloID).collection(coleccion).addDocument(data: data)
    }
    
    // MARK: - Módulo de Negocios (Funciones Independientes)
    
    func fetchBusinesses() async throws -> [Negocio] {
        let collectionPath = FirestoreCollection.negocios(pueblo: self.puebloID).path
        let snapshot = try await db.collection(collectionPath).getDocuments()
        let negocios = try snapshot.documents.compactMap {
            try $0.data(as: Negocio.self)
        }
        return negocios
    }
    
    func fetchLatestNews() async throws -> [ContenidoNegocio] {
        let snapshot = try await db.collectionGroup("Contenido")
            .order(by: "timestamp", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        let novedades = try snapshot.documents.compactMap {
            try $0.data(as: ContenidoNegocio.self)
        }
        return novedades
    }
    
    func postBusinessContent(for businessId: String, content: ContenidoNegocio) async throws {
        let collectionPath = FirestoreCollection.negocios(pueblo: self.puebloID).path
        let newContentRef = db.collection(collectionPath).document(businessId).collection("Contenido").document()
        try newContentRef.setData(from: content)
    }

    func createBusiness(newBusinessData: Negocio, for userId: String) async throws {
        let batch = db.batch()
        
        let businessCollectionPath = FirestoreCollection.negocios(pueblo: self.puebloID).path
        let newBusinessRef = db.collection(businessCollectionPath).document()
        
        let businessToCreate = Negocio(
            id: newBusinessRef.documentID,
            titulo: newBusinessData.titulo,
            logoUrl: newBusinessData.logoUrl,
            adminUID: userId
        )
        try batch.setData(from: businessToCreate, forDocument: newBusinessRef)
        
        let userCollectionPath = FirestoreCollection.usuarios(pueblo: self.puebloID).path
        let userRef = db.collection(userCollectionPath).document(userId)
        
        batch.updateData(["negocioId": newBusinessRef.documentID], forDocument: userRef)
        
        try await batch.commit()
    }
    
    func deleteBusiness(business: Negocio) async throws {
        guard let businessId = business.id else { return }
        
        let batch = db.batch()
        let businessCollectionPath = FirestoreCollection.negocios(pueblo: self.puebloID).path
        let businessRef = db.collection(businessCollectionPath).document(businessId)

        // Borrar la subcolección "Contenido"
        let contentSnapshot = try await businessRef.collection("Contenido").getDocuments()
        for document in contentSnapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        // Desvincular al dueño si lo tiene
        if !business.adminUID.isEmpty {
            let userCollectionPath = FirestoreCollection.usuarios(pueblo: self.puebloID).path
            let userRef = db.collection(userCollectionPath).document(business.adminUID)
            batch.updateData(["negocioId": FieldValue.delete()], forDocument: userRef)
        }
        
        // Borrar el documento principal del negocio
        batch.deleteDocument(businessRef)
        
        // Ejecutar todas las operaciones de borrado
        try await batch.commit()
    }
    func fetchContent(for businessId: String) async throws -> [ContenidoNegocio] {
            let collectionPath = FirestoreCollection.negocios(pueblo: self.puebloID).path
            let snapshot = try await db.collection(collectionPath)
                                       .document(businessId)
                                       .collection("Contenido")
                                       .order(by: "timestamp", descending: true)
                                       .getDocuments()

            return try snapshot.documents.compactMap { try $0.data(as: ContenidoNegocio.self) }
        }
    func fetchAllUsers() async throws -> [Usuario] {
         let collectionPath = FirestoreCollection.usuarios(pueblo: self.puebloID).path
         let snapshot = try await db.collection(collectionPath).getDocuments()
         return snapshot.documents.compactMap { try? $0.data(as: Usuario.self) }
     }
}
