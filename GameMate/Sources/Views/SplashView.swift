import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            // Return nothing as this will be handled by parent view
            EmptyView()
        } else {
            ZStack {
                // Background color that matches your brand
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Image("AppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("GameMate")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // Ensure the splash screen shows for at least 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 