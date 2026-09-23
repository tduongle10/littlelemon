import SwiftUI

extension View {
    func roundedFieldStyle() -> some View {
        self
            .font(.paragraphText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.secondaryLightGray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

func placeholderText(_ text: String) -> Text {
    Text(text).foregroundColor(.primaryGreen)
}
