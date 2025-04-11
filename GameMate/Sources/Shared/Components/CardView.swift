import SwiftUI

/// A reusable card component for consistent styling throughout the app
struct CardView<Content: View>: View {
    var title: String?
    var systemImage: String?
    var backgroundColor: Color = Constants.Colors.cardBackground
    var cornerRadius: CGFloat = Constants.UI.cornerRadius
    var shadowRadius: CGFloat = 3
    var padding: CGFloat = Constants.UI.standardPadding
    let content: Content
    
    init(
        title: String? = nil,
        systemImage: String? = nil,
        backgroundColor: Color = Constants.Colors.cardBackground,
        cornerRadius: CGFloat = Constants.UI.cornerRadius,
        shadowRadius: CGFloat = 3,
        padding: CGFloat = Constants.UI.standardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || systemImage != nil {
                HStack {
                    if let icon = systemImage {
                        Image(systemName: icon)
                            .font(.headline)
                            .foregroundColor(Constants.Colors.primary)
                    }
                    
                    if let cardTitle = title {
                        Text(cardTitle)
                            .font(.headline)
                    }
                    
                    Spacer()
                }
            }
            
            content
        }
        .padding(padding)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: shadowRadius, x: 0, y: 2)
    }
}

// Extension to make any view into a card
extension View {
    func asCard(
        title: String? = nil,
        systemImage: String? = nil,
        backgroundColor: Color = Constants.Colors.cardBackground,
        cornerRadius: CGFloat = Constants.UI.cornerRadius,
        shadowRadius: CGFloat = 3,
        padding: CGFloat = Constants.UI.standardPadding
    ) -> some View {
        CardView(
            title: title,
            systemImage: systemImage,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            padding: padding
        ) {
            self
        }
    }
}

#Preview {
    VStack {
        CardView(title: "Example Card", systemImage: "star.fill") {
            Text("This is a card with content inside")
                .padding()
        }
        .padding()
        
        Text("Some content")
            .padding()
            .asCard(title: "Card Extension", systemImage: "circle.fill")
            .padding()
    }
} 