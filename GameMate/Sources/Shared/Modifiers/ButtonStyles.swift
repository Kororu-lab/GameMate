import SwiftUI

/// Primary button style with a fill background
struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = Constants.Colors.primary
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(Constants.UI.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style with an outline
struct SecondaryButtonStyle: ButtonStyle {
    var borderColor: Color = Constants.Colors.primary
    var foregroundColor: Color = Constants.Colors.primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(configuration.isPressed ? .white : foregroundColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                configuration.isPressed ? 
                    borderColor.opacity(0.7) : 
                    Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(Constants.UI.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Icon button style for compact buttons with just an icon
struct IconButtonStyle: ButtonStyle {
    var backgroundColor: Color = Constants.Colors.primary
    var size: CGFloat = 44
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(size/2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Button style extensions for easier use
extension Button {
    func primaryStyle(backgroundColor: Color = Constants.Colors.primary) -> some View {
        self.buttonStyle(PrimaryButtonStyle(backgroundColor: backgroundColor))
    }
    
    func secondaryStyle(borderColor: Color = Constants.Colors.primary) -> some View {
        self.buttonStyle(SecondaryButtonStyle(borderColor: borderColor))
    }
    
    func iconStyle(backgroundColor: Color = Constants.Colors.primary, size: CGFloat = 44) -> some View {
        self.buttonStyle(IconButtonStyle(backgroundColor: backgroundColor, size: size))
    }
} 