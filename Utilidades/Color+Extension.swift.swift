//
//  Color+Extension.swift.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 28/6/25.
//

//
//  Color+Extension.swift
//  FigueruelasConecta
//
//  Created by TuPuebloConecta on [Fecha Actual].
//

import Foundation
import SwiftUI

extension Color {
    
    // MARK: - Colores Corporativos y de la App
    
    /// Color naranja principal usado en botones y elementos destacados.
    /// HEX: #E65100
    static let naranjaPrincipal = Color(hex: "#E65100")
    
    /// Azul oscuro para enlaces como "¿Olvidaste tu contraseña?".
    /// HEX: #283593
    static let azulLink = Color(hex: "#283593")
    
    
    // MARK: - Colores de Texto
    
    /// Color de texto principal, casi negro.
    /// HEX: #212121
    static let grisTextoPrincipal = Color(hex: "#212121")

    /// Color de texto para los placeholders (pistas) en los campos de texto.
    /// HEX: #757575
    static let grisTextoPlaceholder = Color(hex: "#757575")

    
    // MARK: - Colores de Fondo
    
    /// Fondo blanco semitransparente para los campos de texto del login.
    /// HEX: #B3FFFFFF
    static let blancoFondoInput = Color(hex: "#B3FFFFFF")
    
    
    // MARK: - Inicializador para Colores HEX
    
    /// Permite crear un color usando un código hexadecimal como en la web o Android.
    /// Admite formatos de 3, 6 y 8 dígitos (con alfa), con o sin el prefijo "#".
    /// Ejemplos: Color(hex: "#FFF"), Color(hex: "E65100"), Color(hex: "#B3FFFFFF")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
        // Pequeño modelo para representar cada elemento del menú
        struct MenuItem: Identifiable {
            let id = UUID()
            let title: String
            let icon: String // Usaremos SFSymbols de Apple para los iconos
            let color: Color
            let destination: AnyView // La vista a la que navegará
        }
    }
}
