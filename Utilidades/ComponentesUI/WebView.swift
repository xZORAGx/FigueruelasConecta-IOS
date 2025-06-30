import SwiftUI
import WebKit // Necesitamos importar WebKit

// Este es nuestro "puente" reutilizable entre SwiftUI y WKWebView de UIKit
struct WebView: UIViewRepresentable {
    
    // La URL que queremos cargar
    let urlString: String

    // 1. Crea la vista de UIKit (WKWebView) y la configura una sola vez.
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Habilitamos JavaScript, igual que en tu código Android
        webView.configuration.preferences.javaScriptEnabled = true
        return webView
    }

    // 2. Actualiza la vista de UIKit cuando algo cambia en SwiftUI.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
