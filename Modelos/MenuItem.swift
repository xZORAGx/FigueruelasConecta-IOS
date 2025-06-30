import SwiftUI

// Modelo para los botones con imágenes de fondo
struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String // El nombre de tu imagen en Assets.xcassets
    let destination: AnyView
}
