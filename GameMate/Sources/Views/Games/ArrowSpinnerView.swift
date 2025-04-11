import SwiftUI

struct ArrowSpinnerView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning: Bool = false
    @State private var direction: Double = 0
    @State private var selectedPosition: Int? = nil
    
    var body: some View {
        VStack {
            Text("Arrow Spinner")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            ZStack {
                // Background circle to represent a table
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                
                // Arrow
                Arrow()
                    .stroke(Color.red, lineWidth: 4)
                    .frame(width: 240, height: 20)
                    .rotationEffect(Angle(degrees: rotationDegrees))
                
                // Center circle
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .shadow(color: .gray, radius: 2)
            }
            .frame(width: 300, height: 300)
            .onTapGesture {
                if !isSpinning {
                    spinArrow()
                }
            }
            
            Spacer()
            
            Button(action: {
                if !isSpinning {
                    spinArrow()
                }
            }) {
                Text("Spin")
                    .font(.title2)
                    .padding()
                    .frame(minWidth: 120)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isSpinning)
            .padding(.bottom, 40)
        }
    }
    
    private func spinArrow() {
        isSpinning = true
        selectedPosition = nil
        
        // Calculate random number of full rotations (2-10) plus a random angle
        let rotations = Double.random(in: 2...10)
        let randomAngle = Double.random(in: 0..<360)
        let totalRotation = rotations * 360 + randomAngle
        
        // Calculate spin duration based on rotation amount (3-5 seconds)
        let duration = Double.random(in: 3...5)
        
        // Animate the spin with easing
        withAnimation(.easeInOut(duration: duration)) {
            rotationDegrees += totalRotation
        }
        
        // After the spin is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isSpinning = false
            
            // Calculate final position (0-359 degrees)
            let normalizedAngle = Int(rotationDegrees.truncatingRemainder(dividingBy: 360))
            
            // Log the result
            appModel.addLogEntry(
                type: .arrow,
                result: "Arrow pointed to \(normalizedAngle)°"
            )
        }
    }
}

// Arrow shape
struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from middle left (arrow tail)
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        // Draw to right side
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        
        // Draw arrow head
        path.move(to: CGPoint(x: rect.width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width - 20, y: rect.midY - 10))
        path.move(to: CGPoint(x: rect.width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width - 20, y: rect.midY + 10))
        
        return path
    }
}

#Preview {
    ArrowSpinnerView()
        .environmentObject(AppModel())
} 