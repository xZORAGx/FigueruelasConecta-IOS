// 📂 Servicios (Services)
// └── NavigationManager.swift

import Foundation
import Combine

// --- CORRECCIÓN AQUÍ ---
// El enum ahora solo incluye los casos que reciben notificaciones.
enum ScreenDestination: String {
    case noticias
    case empleo
    case celebraciones // Corresponde a "Fiestas" en la UI
    case actividades   // Corresponde a "Deportes" en la UI
}

// El resto del archivo no cambia
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var destination: ScreenDestination?
    private init() {}
}
