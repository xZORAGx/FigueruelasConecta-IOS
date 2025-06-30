import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            // El fondo degradado que tenías
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#141E30"), Color(hex: "#243B55")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // El logo de la app
                Image("escudofigueruelas")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.bottom, 30)
                
                // La rueda de carga
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}
