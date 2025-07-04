import SwiftUI

struct NegocioRowView: View {
    let negocio: Negocio
    let isSelectionActive: Bool
    let isSelected: Bool

    var body: some View {
        HStack {
            if isSelectionActive {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .blue)
                    .font(.title2)
            }
            
            AsyncImage(url: URL(string: negocio.logoUrl)) { image in
                image.resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: 50, height: 50)
                     .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                Image(systemName: "photo.artframe")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                    .frame(width: 50, height: 50)
            }
            
            Text(negocio.titulo)
                .font(.headline)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
