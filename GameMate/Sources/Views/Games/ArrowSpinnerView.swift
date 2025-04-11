import SwiftUI

struct ArrowSpinnerView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning: Bool = false
    @State private var direction: Double = 0
    @State private var selectedPosition: Int? = nil
    
    var body: some View {
        VStack {
            Text("Arrow Spinner".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            ZStack {
                // Background circle to represent a table
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                
                // Arrow
                Arrow()
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 240, height: 20)
                    .rotationEffect(Angle(degrees: rotationDegrees))
                
                // Center circle
                Circle()
                    .fill(Color.white)
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
            
            if !isSpinning && selectedPosition != nil {
                Text("Result: \(Int(rotationDegrees.truncatingRemainder(dividingBy: 360)))°".localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            
            Button(action: {
                if !isSpinning {
                    spinArrow()
                }
            }) {
                Text("Spin".localized)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSpinning ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isSpinning)
            .padding()
            
            NavigationLink(destination: HistoryView(selectedFilter: .arrow)) {
                Text("View History".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
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
            selectedPosition = normalizedAngle
            
            // Log the result
            appModel.addLogEntry(
                type: .arrow,
                result: String(format: "Arrow pointed to %@°".localized, String(normalizedAngle))
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