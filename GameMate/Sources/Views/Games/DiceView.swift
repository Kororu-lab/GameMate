import SwiftUI

struct DiceView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var diceValues: [Int] = [1]
    @State private var isRolling = false
    @State private var rotationAngles: [Double] = [0]
    @State private var scales: [CGFloat] = [1.0]
    @State private var offsets: [CGSize] = [.zero]
    
    var body: some View {
        VStack {
            Text("Dice Roller".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Text(String(format: "Number of dice: %@".localized, String(appModel.diceCount)))
                Spacer()
                Stepper("", value: $appModel.diceCount, in: 1...6, step: 1)
                    .onChange(of: appModel.diceCount) { _, newValue in
                        // Only update if not currently rolling
                        if !isRolling {
                            updateDiceArrays(count: newValue)
                        } else {
                            // If rolling, revert to previous count
                            DispatchQueue.main.async {
                                appModel.diceCount = diceValues.count
                            }
                        }
                    }
                    .disabled(isRolling)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack {
                if appModel.diceCount <= 3 {
                    HStack(spacing: 20) {
                        ForEach(0..<diceValues.count, id: \.self) { index in
                            DiceView2D(
                                value: diceValues[index],
                                color: appModel.useSameColorForDice ? appModel.diceColor : appModel.diceColors[min(index, appModel.diceColors.count - 1)],
                                rotationAngle: rotationAngles[index],
                                scale: scales[index],
                                offset: offsets[index]
                            )
                            .frame(width: 120, height: 120)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        // First row: Always show up to 3 dice
                        HStack(spacing: 20) {
                            ForEach(0..<min(3, diceValues.count), id: \.self) { index in
                                DiceView2D(
                                    value: diceValues[index],
                                    color: appModel.useSameColorForDice ? appModel.diceColor : appModel.diceColors[min(index, appModel.diceColors.count - 1)],
                                    rotationAngle: rotationAngles[index],
                                    scale: scales[index],
                                    offset: offsets[index]
                                )
                                .frame(width: 100, height: 100)
                            }
                        }
                        
                        // Second row: Only show if there are more than 3 dice
                        if diceValues.count > 3 {
                            HStack(spacing: 20) {
                                ForEach(Array(diceValues[3...].enumerated()), id: \.offset) { index, _ in
                                    DiceView2D(
                                        value: diceValues[index + 3],
                                        color: appModel.useSameColorForDice ? appModel.diceColor : appModel.diceColors[min(index + 3, appModel.diceColors.count - 1)],
                                        rotationAngle: rotationAngles[index + 3],
                                        scale: scales[index + 3],
                                        offset: offsets[index + 3]
                                    )
                                    .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            Text(String(format: "Total: %@".localized, String(diceValues.reduce(0, +))))
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
            
            Button(action: rollDice) {
                Text("Roll Dice".localized)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRolling ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isRolling)
            .padding()
            
            NavigationLink(destination: HistoryView(selectedFilter: .dice)) {
                Text("View History".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .onAppear {
            updateDiceArrays(count: appModel.diceCount)
        }
    }
    
    private func updateDiceArrays(count: Int) {
        let currentCount = diceValues.count
        
        if count > currentCount {
            // Add more dice
            diceValues.append(contentsOf: Array(repeating: 1, count: count - currentCount))
            rotationAngles.append(contentsOf: Array(repeating: 0.0, count: count - currentCount))
            scales.append(contentsOf: Array(repeating: 1.0, count: count - currentCount))
            offsets.append(contentsOf: Array(repeating: CGSize.zero, count: count - currentCount))
        } else if count < currentCount {
            // Remove dice
            diceValues.removeSubrange(count..<currentCount)
            rotationAngles.removeSubrange(count..<currentCount)
            scales.removeSubrange(count..<currentCount)
            offsets.removeSubrange(count..<currentCount)
        }
    }
    
    private func rollDice() {
        guard !isRolling else { return }
        isRolling = true
        
        // Prepare new results first
        let newValues = (0..<diceValues.count).map { _ in Int.random(in: 1...6) }
        
        // Reset all animation values to ensure consistent behavior
        for i in 0..<diceValues.count {
            rotationAngles[i] = 0
            scales[i] = 1.0
            offsets[i] = .zero
        }
        
        // STEP 1: Initial jump animation - dice get thrown up
        withAnimation(.easeOut(duration: 0.3)) {
            for i in 0..<diceValues.count {
                scales[i] = 1.4
                offsets[i] = CGSize(width: CGFloat.random(in: -5...5), height: -50)
            }
        }
        
        // STEP 2: Main tumbling animation - dice spin in the air
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            for i in 0..<diceValues.count {
                // Random full rotations (between 2-3 full rotations)
                let rotations = Double.random(in: 720...1080)
                
                withAnimation(.easeInOut(duration: 1.2)) {
                    rotationAngles[i] = rotations
                    // Move slightly horizontally for natural feel
                    offsets[i] = CGSize(width: CGFloat.random(in: -30...30), height: -10)
                }
            }
        }
        
        // STEP 3: Landing bounce animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                for i in 0..<diceValues.count {
                    // Land with a slight bounce
                    offsets[i] = CGSize(width: offsets[i].width * 0.5, height: 10)
                    scales[i] = 1.1
                    // Add a small random rotation at landing for realism
                    rotationAngles[i] += Double.random(in: -30...30)
                }
            }
        }
        
        // STEP 4: Final settling with slight roll to final position
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.spring(dampingFraction: 0.6, blendDuration: 0.3)) {
                for i in 0..<diceValues.count {
                    // Final position
                    offsets[i] = .zero
                    scales[i] = 1.0
                    
                    // Ensure each die ends up with a rotation that looks random
                    // but still looks good from the user's perspective
                    rotationAngles[i] = Double(Int(rotationAngles[i]) % 90) + Double.random(in: -5...5)
                }
            }
            
            // Update the results in the model
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                diceValues = newValues
                
                // Log the result
                let resultString = diceValues.map { String($0) }.joined(separator: ", ")
                appModel.addLogEntry(type: .dice, result: String(format: "Rolled: %@ (Total: %@)".localized, resultString, String(diceValues.reduce(0, +))))
                
                isRolling = false
            }
        }
    }
}

struct DiceView2D: View {
    var value: Int
    var color: Color
    var rotationAngle: Double
    var scale: CGFloat
    var offset: CGSize
    
    var body: some View {
        ZStack {
            // Dice body with 3D-like shadows
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
                .overlay(
                    // Light reflection effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Dice dots
            DiceDots(value: value)
                .padding(20)
        }
        .rotationEffect(.degrees(rotationAngle))
        .scaleEffect(scale)
        .offset(offset)
    }
}

struct DiceDots: View {
    var value: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Center dot (for 1, 3, 5)
                if [1, 3, 5].contains(value) {
                    DiceDot()
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                }
                
                // Top-Left and Bottom-Right (for 2, 3, 4, 5, 6)
                if [2, 3, 4, 5, 6].contains(value) {
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.25,
                            y: geometry.size.height * 0.25
                        )
                    
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.75,
                            y: geometry.size.height * 0.75
                        )
                }
                
                // Top-Right and Bottom-Left (for 4, 5, 6)
                if [4, 5, 6].contains(value) {
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.75,
                            y: geometry.size.height * 0.25
                        )
                    
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.25,
                            y: geometry.size.height * 0.75
                        )
                }
                
                // Middle-Left and Middle-Right (for 6)
                if value == 6 {
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.25,
                            y: geometry.size.height * 0.5
                        )
                    
                    DiceDot()
                        .position(
                            x: geometry.size.width * 0.75,
                            y: geometry.size.height * 0.5
                        )
                }
            }
        }
    }
}

struct DiceDot: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 12, height: 12)
            .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
    }
}

#Preview {
    DiceView()
        .environmentObject(AppModel())
} 