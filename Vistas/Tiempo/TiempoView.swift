import SwiftUI

struct TiempoView: View {
    
    private let urlTiempo = "https://www.msn.com/es-es/eltiempo/prevision/in-Figueruelas,Arag%C3%B3n?loc=eyJsIjoiRmlndWVydWVsYXMiLCJyIjoiQXJhZ8OzbiIsInIyIjoiWmFyYWdvemEiLCJjIjoiRXNwYcOxYSIsImkiOiJFUyIsInQiOjEwMiwiZyI6ImVzLWVzIiwieCI6Ii0xLjE3NTQiLCJ5IjoiNDEuNzY2NiJ9&weadegreetype=C"
    
    var body: some View {
        // ================================================================
        // IMPORTANTE: Esta vista solo debe devolver el WebView.
        // NO debe tener un 'NavigationStack' aquí.
        // AppTabView ya se encarga de ponerlo por fuera.
        // ================================================================
        WebView(urlString: urlTiempo)
    }
}

#Preview {
    // La preview sí necesita su propio NavigationStack para verse bien
    NavigationStack {
        TiempoView()
            .standardToolbar()
    }
}
