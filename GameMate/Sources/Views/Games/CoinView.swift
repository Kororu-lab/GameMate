import SwiftUI

struct CoinView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var coinResults: [Bool] = [true]
    @State private var isTossing = false
    @State private var rotationAngles: [Double] = [0]
    @State private var flipRotations: [Double] = [0]
    @State private var scales: [CGFloat] = [1.0]
    @State private var offsets: [CGSize] = [.zero]
    @State private var coinCount = 1
    
    var body: some View {
        VStack {
            Text("Coin Toss".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Text("Number of coins: \(coinCount)".localized)
                Spacer()
                Stepper("", value: $coinCount, in: 1...6, step: 1)
                    .onChange(of: coinCount) { _, newValue in
                        // Only update if not currently tossing
                        if !isTossing {
                            updateCoinArrays(count: newValue)
                        } else {
                            // If tossing, revert to previous count
                            DispatchQueue.main.async {
                                coinCount = coinResults.count
                            }
                        }
                    }
                    .disabled(isTossing)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack {
                if coinCount <= 3 {
                    HStack(spacing: 20) {
                        ForEach(0..<coinResults.count, id: \.self) { index in
                            CoinView2D(
                                isHeads: coinResults[index], 
                                rotationAngle: rotationAngles[index],
                                flipRotation: flipRotations[index],
                                scale: scales[index],
                                offset: offsets[index],
                                color: appModel.useSameColorForCoins ? appModel.coinColor : appModel.coinColors[min(index, appModel.coinColors.count - 1)]
                            )
                            .frame(width: 120, height: 120)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            ForEach(0..<min(3, coinResults.count), id: \.self) { index in
                                CoinView2D(
                                    isHeads: coinResults[index], 
                                    rotationAngle: rotationAngles[index],
                                    flipRotation: flipRotations[index],
                                    scale: scales[index],
                                    offset: offsets[index],
                                    color: appModel.useSameColorForCoins ? appModel.coinColor : appModel.coinColors[min(index, appModel.coinColors.count - 1)]
                                )
                                .frame(width: 100, height: 100)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            ForEach(3..<coinResults.count, id: \.self) { index in
                                CoinView2D(
                                    isHeads: coinResults[index], 
                                    rotationAngle: rotationAngles[index],
                                    flipRotation: flipRotations[index],
                                    scale: scales[index],
                                    offset: offsets[index],
                                    color: appModel.useSameColorForCoins ? appModel.coinColor : appModel.coinColors[min(index, appModel.coinColors.count - 1)]
                                )
                                .frame(width: 100, height: 100)
                            }
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            if !isTossing {
                let headsCount = coinResults.filter { $0 }.count
                let tailsCount = coinResults.count - headsCount
                
                Text("Results: \(headsCount) Heads, \(tailsCount) Tails".localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            
            Button(action: tossCoin) {
                Text("Toss Coins".localized)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isTossing ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isTossing)
            .padding()
            
            NavigationLink(destination: HistoryView(selectedFilter: .coin)) {
                Text("View History".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .onAppear {
            updateCoinArrays(count: coinCount)
        }
    }
    
    private func updateCoinArrays(count: Int) {
        let currentCount = coinResults.count
        
        if count > currentCount {
            // Add more coins
            coinResults.append(contentsOf: Array(repeating: true, count: count - currentCount))
            rotationAngles.append(contentsOf: Array(repeating: 0.0, count: count - currentCount))
            flipRotations.append(contentsOf: Array(repeating: 0.0, count: count - currentCount))
            scales.append(contentsOf: Array(repeating: 1.0, count: count - currentCount))
            offsets.append(contentsOf: Array(repeating: CGSize.zero, count: count - currentCount))
        } else if count < currentCount {
            // Remove coins
            coinResults.removeSubrange(count..<currentCount)
            rotationAngles.removeSubrange(count..<currentCount)
            flipRotations.removeSubrange(count..<currentCount)
            scales.removeSubrange(count..<currentCount)
            offsets.removeSubrange(count..<currentCount)
        }
    }
    
    private func tossCoin() {
        guard !isTossing else { return }
        isTossing = true
        
        // Prepare new results first
        let newResults = (0..<coinResults.count).map { _ in Bool.random() }
        
        // Reset all animation values to ensure consistent behavior
        for i in 0..<coinResults.count {
            rotationAngles[i] = 0
            flipRotations[i] = 0
            scales[i] = 1.0
            offsets[i] = .zero
        }
        
        // STEP 1: Initial toss up animation
        withAnimation(.easeOut(duration: 0.3)) {
            for i in 0..<coinResults.count {
                scales[i] = 1.2
                offsets[i] = CGSize(width: CGFloat.random(in: -10...10), height: -30)
            }
        }
        
        // STEP 2: Main flipping animation - guaranteed to have multiple complete flips
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            for i in 0..<coinResults.count {
                // Always do at least 4 complete flips (1440 degrees) plus a bit more
                // This ensures the coin spins enough to look natural
                let minimumFlips = 4 * 360
                let extraRotation = Int.random(in: 0...200)
                
                // Ensure the final position shows the correct result
                // If heads, end at a multiple of 360 degrees
                // If tails, end at 180 + multiple of 360 degrees
                let finalPosition = newResults[i] ? 0.0 : 180.0
                let totalFlipRotation = Double(minimumFlips + extraRotation) + finalPosition
                
                // Horizontal rotation (like a coin spinning on a table)
                let spinRotation = Double.random(in: 60...180) * (Bool.random() ? 1 : -1)
                
                withAnimation(.easeInOut(duration: 1.2)) {
                    flipRotations[i] = totalFlipRotation
                    rotationAngles[i] = spinRotation
                    // Move the coin in the air a bit - slight horizontal movement is natural
                    offsets[i] = CGSize(width: CGFloat.random(in: -15...15), height: -10)
                }
            }
        }
        
        // STEP 3: Landing phase - bounce with slight wobble
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                for i in 0..<coinResults.count {
                    // Keep the same rotations but make the coin fall and bounce
                    offsets[i] = CGSize(width: offsets[i].width * 0.5, height: 5)
                    scales[i] = 1.1
                }
            }
        }
        
        // STEP 4: Settling phase - make sure the coin remains in correct orientation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.spring(dampingFraction: 0.7, blendDuration: 0.3)) {
                for i in 0..<coinResults.count {
                    // Final position and scale
                    offsets[i] = .zero
                    scales[i] = 1.0
                    
                    // Ensure the coin shows the correct face
                    let finalRotation = newResults[i] ? 0.0 : 180.0
                    flipRotations[i] = finalRotation
                }
            }
            
            // Update the results in the model
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                coinResults = newResults
                
                // Log the result
                let headsCount = newResults.filter { $0 }.count
                let tailsCount = newResults.count - headsCount
                appModel.addLogEntry(type: .coin, result: "Tossed \(newResults.count) coins: \(headsCount) Heads, \(tailsCount) Tails")
                
                isTossing = false
            }
        }
    }
}

struct CoinView2D: View {
    var isHeads: Bool
    var rotationAngle: Double
    var flipRotation: Double
    var scale: CGFloat
    var offset: CGSize
    var color: Color
    
    var body: some View {
        ZStack {
            // The coin
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.lighter(by: 10),
                            color.darker(by: 10) ?? color
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.lighter(by: 20),
                                    color.darker(by: 20) ?? color
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 4
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                .overlay(
                    CoinFace(isHeads: true)
                        .opacity(isFaceVisible(isHeads: true, flipRotation: flipRotation))
                )
                .overlay(
                    CoinFace(isHeads: false)
                        .opacity(isFaceVisible(isHeads: false, flipRotation: flipRotation))
                )
        }
        .rotation3DEffect(
            .degrees(flipRotation),
            axis: (x: 1.0, y: 0.0, z: 0.0),  // Use a pure x-axis rotation for consistent flipping
            perspective: 0.3  // Add perspective for more realistic 3D effect
        )
        .rotationEffect(.degrees(rotationAngle))  // 2D rotation (spin)
        .scaleEffect(scale)
        .offset(offset)
    }
    
    // Helper function to determine if a face should be visible based on the current rotation
    private func isFaceVisible(isHeads: Bool, flipRotation: Double) -> Double {
        // Normalize the rotation to 0-360 degrees
        let normalizedRotation = ((flipRotation.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        
        // When rotation is between 0-90 or 270-360 degrees, we see the heads side
        // When rotation is between 90-270 degrees, we see the tails side
        let isHeadsVisible = (normalizedRotation < 90 || normalizedRotation > 270)
        
        // Return 1.0 (fully visible) if this face should be shown, 0.0 (invisible) otherwise
        return (isHeads == isHeadsVisible) ? 1.0 : 0.0
    }
}

struct CoinFace: View {
    var isHeads: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                
                if isHeads {
                    Text("H".localized)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.1))
                    
                    // Small decorative circles around the edge
                    ForEach(0..<12) { index in
                        let angle = Double(index) * (360.0 / 12.0)
                        Circle()
                            .fill(Color(red: 0.7, green: 0.5, blue: 0.1))
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(angle * .pi / 180) * 40,
                                y: sin(angle * .pi / 180) * 40
                            )
                    }
                } else {
                    Text("T".localized)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.1))
                    
                    // Small decorative dots in a different pattern
                    ForEach(0..<8) { index in
                        let angle = Double(index) * (360.0 / 8.0)
                        Circle()
                            .fill(Color(red: 0.7, green: 0.5, blue: 0.1))
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(angle * .pi / 180) * 35,
                                y: sin(angle * .pi / 180) * 35
                            )
                    }
                }
            }
        }
    }
}

// Extensions to make color lighter or darker
extension Color {
    func lighter(by percentage: CGFloat = 30) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30) -> Color? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(
                red: min(1.0, max(0, red + percentage/100)),
                green: min(1.0, max(0, green + percentage/100)),
                blue: min(1.0, max(0, blue + percentage/100)),
                opacity: alpha
            )
        }
        return self
    }
}

#Preview {
    CoinView()
        .environmentObject(AppModel())
} 