import SwiftUI

struct LadderGameView: View {
    @EnvironmentObject private var appModel: AppModel
    // Default ladder count
    @State private var ladderCount: Int = 4
    @State private var horizontalLines: [[Bool]] = []
    @State private var selectedLadder: Int? = nil
    @State private var pathPoints: [CGPoint] = []
    @State private var isAnimating: Bool = false
    @State private var showResult: Bool = false
    @State private var showHorizontalLines: Bool = false // Show horizontal lines
    @State private var ladderViewSize: CGSize = .zero // Store ladder view size
    
    // Different colors array
    private let colors: [Color] = [
        .red, .blue, .green, .orange, .purple, .pink,
        .yellow, .teal, .indigo, .cyan, .mint, .brown
    ]
    
    var body: some View {
        VStack {
            Text("Ladder Game".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Ladder count control
            HStack {
                Text(String(format: "Number of ladders: %@".localized, String(ladderCount)))
                Spacer()
                Stepper("", value: $ladderCount, in: 2...6)
                    .onChange(of: ladderCount) { _, _ in
                        withAnimation {
                            resetGame()
                        }
                    }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Ladder game screen
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 400)
                
                // Draw ladder
                LadderView(
                    count: ladderCount,
                    horizontalLines: horizontalLines,
                    pathPoints: pathPoints,
                    selectedLadder: selectedLadder,
                    showResult: showResult,
                    showHorizontalLines: showHorizontalLines,
                    colors: colors,
                    onStartSelected: { index, point in
                        tracePath(from: index, startPoint: point)
                    },
                    onSizeChanged: { size in
                        ladderViewSize = size
                    }
                )
                .padding()
                .frame(height: 380)
            }
            .padding()
            
            Spacer()
            
            // Show result
            if showResult, let selected = selectedLadder {
                Text(String(format: "Result: %@".localized, String(selected + 1)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            
            HStack(spacing: 20) {
                // Reset button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        resetGame(generateNewLines: false)
                    }
                }) {
                    Text("Reset".localized)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                // Shuffle button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        resetGame(generateNewLines: true)
                    }
                }) {
                    Text("Shuffle".localized)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            NavigationLink(destination: HistoryView(selectedFilter: nil)) {
                Text("View History".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .onAppear {
            resetGame(generateNewLines: true)
        }
    }
    
    private func resetGame(generateNewLines: Bool = true) {
        // Reset state
        selectedLadder = nil
        pathPoints = []
        showResult = false
        isAnimating = false
        showHorizontalLines = false 
        
        // Only generate new horizontal lines if needed
        if generateNewLines {
            generateHorizontalLines()
        }
    }
    
    private func generateHorizontalLines() {
        horizontalLines = []
        
        // Number of horizontal layers in the ladder
        let ladderHeight = 6
        
        for _ in 0..<ladderHeight {
            var rowLines = [Bool](repeating: false, count: ladderCount - 1)
            
            // Randomly create horizontal lines for each layer
            for i in 0..<ladderCount - 1 {
                // Prevent consecutive horizontal lines
                if i > 0 && rowLines[i - 1] {
                    rowLines[i] = false
                } else {
                    rowLines[i] = Bool.random()
                }
            }
            
            horizontalLines.append(rowLines)
        }
    }
}

struct LadderView: View {
    let count: Int
    let horizontalLines: [[Bool]]
    let pathPoints: [CGPoint]
    let selectedLadder: Int?
    let showResult: Bool
    let showHorizontalLines: Bool
    let colors: [Color]
    let onStartSelected: (Int, CGPoint) -> Void
    let onSizeChanged: (CGSize) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw vertical lines
                ForEach(0..<count, id: \.self) { i in
                    let x = self.getXPosition(for: i, in: geometry)
                    
                    VStack {
                        // Start point (top circle)
                        Circle()
                            .fill(colors[i % colors.count])
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                let circleCenter = CGPoint(x: x, y: 30)
                                onStartSelected(i, circleCenter)
                            }
                        
                        Spacer()
                    }
                    .position(x: x, y: geometry.size.height / 2)
                    
                    // Vertical line
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 30))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height - 30))
                    }
                    .stroke(selectedLadder == nil || selectedLadder == i ? Color.gray : Color.gray.opacity(0.3), lineWidth: 2)
                    
                    VStack {
                        Spacer()
                        
                        // End point (bottom circle)
                        Circle()
                            .fill(showResult && selectedLadder == i ? colors[selectedLadder! % colors.count] : Color.red)
                            .frame(width: 30, height: 30)
                    }
                    .position(x: x, y: geometry.size.height / 2)
                }
                
                // Draw horizontal lines - only visible after selection
                ForEach(0..<horizontalLines.count, id: \.self) { row in
                    ForEach(0..<horizontalLines[row].count, id: \.self) { col in
                        if horizontalLines[row][col] {
                            let leftX = self.getXPosition(for: col, in: geometry)
                            let rightX = self.getXPosition(for: col + 1, in: geometry)
                            let y = self.getYPosition(for: row, in: geometry)
                            
                            Path { path in
                                path.move(to: CGPoint(x: leftX, y: y))
                                path.addLine(to: CGPoint(x: rightX, y: y))
                            }
                            .stroke(Color.gray, lineWidth: 2)
                            .opacity(showHorizontalLines ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showHorizontalLines)
                        }
                    }
                }
                
                // Draw the selected path
                if pathPoints.count >= 2 {
                    Path { path in
                        path.move(to: pathPoints[0])
                        
                        for i in 1..<pathPoints.count {
                            path.addLine(to: pathPoints[i])
                        }
                    }
                    .stroke(
                        selectedLadder != nil ? colors[selectedLadder! % colors.count] : Color.red,
                        lineWidth: 4
                    )
                }
            }
            .onAppear {
                onSizeChanged(geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                onSizeChanged(newSize)
            }
        }
    }
    
    private func getXPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let spacing = geometry.size.width / CGFloat(count + 1)
        return spacing * CGFloat(index + 1)
    }
    
    private func getYPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let usableHeight = geometry.size.height - 60 // Account for top and bottom circles
        let spacing = usableHeight / CGFloat(horizontalLines.count + 1)
        return 30 + spacing * CGFloat(index + 1)
    }
}

extension LadderGameView {
    func tracePath(from startIndex: Int, startPoint: CGPoint) {
        guard !isAnimating && !showResult else { return }
        guard startIndex >= 0 && startIndex < ladderCount else { return }
        
        isAnimating = true
        selectedLadder = startIndex
        pathPoints = []
        
        // Show horizontal lines with animation
        withAnimation(.easeIn(duration: 0.3)) {
            showHorizontalLines = true
        }
        
        // Wait briefly then start path animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Calculate all path points in advance for smoother animation
            let allPathPoints = self.calculateFullPath(startCol: startIndex, startPoint: startPoint)
            
            // Add each point with animation delay
            self.animatePathPoints(points: allPathPoints)
        }
    }
    
    // Calculate the full path in advance to ensure correct routing
    private func calculateFullPath(startCol: Int, startPoint: CGPoint) -> [CGPoint] {
        var points = [CGPoint]()
        var currentCol = startCol
        
        // Use the exact provided starting point
        points.append(startPoint)
        
        // For each row, determine path movement
        for row in 0..<horizontalLines.count {
            let currentY = getYPosition(for: row, height: ladderViewSize.height, lines: horizontalLines.count)
            
            // Check if there's a horizontal line to the right
            let goRight = currentCol < ladderCount - 1 && 
                currentCol < horizontalLines[row].count && 
                horizontalLines[row][currentCol]
            
            // Check if there's a horizontal line to the left
            let goLeft = currentCol > 0 && 
                currentCol - 1 < horizontalLines[row].count && 
                horizontalLines[row][currentCol - 1]
            
            if goRight {
                // Add point at current position before moving right
                let currentX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
                points.append(CGPoint(x: currentX, y: currentY))
                
                // Move right
                currentCol += 1
                let nextX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
                points.append(CGPoint(x: nextX, y: currentY))
            } else if goLeft {
                // Add point at current position before moving left
                let currentX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
                points.append(CGPoint(x: currentX, y: currentY))
                
                // Move left
                currentCol -= 1
                let nextX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
                points.append(CGPoint(x: nextX, y: currentY))
            }
            
            // Always add a point for vertical movement
            if row < horizontalLines.count - 1 {
                let nextY = getYPosition(for: row + 1, height: ladderViewSize.height, lines: horizontalLines.count)
                let currentX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
                points.append(CGPoint(x: currentX, y: nextY))
            }
        }
        
        // Add end point at the bottom circle
        let endY = ladderViewSize.height - 30.0
        let endX = getXPosition(for: currentCol, width: ladderViewSize.width, count: ladderCount)
        points.append(CGPoint(x: endX, y: endY))
        
        return points
    }
    
    // Animate through the points one by one with delay
    private func animatePathPoints(points: [CGPoint]) {
        guard !points.isEmpty else { return }
        
        // The first point is already added to pathPoints array
        self.pathPoints = [points[0]]
        
        let totalDuration = 1.5 // Total animation time
        let pointDelay = totalDuration / Double(points.count)
        
        for i in 1..<points.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * pointDelay) {
                // Only proceed if we're still animating (avoid race conditions)
                guard self.isAnimating else { return }
                
                self.pathPoints.append(points[i])
                
                // When we reach the end point
                if i == points.count - 1 {
                    // Determine the final column from the end point x-coordinate
                    let endPointX = points[i].x
                    let finalCol = self.getFinalColumn(from: endPointX)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.selectedLadder = finalCol
                        self.showResult = true
                        self.isAnimating = false
                    }
                }
            }
        }
    }
    
    // Calculate the column index from the x position
    private func getFinalColumn(from x: CGFloat) -> Int {
        let spacing = ladderViewSize.width / CGFloat(ladderCount + 1)
        let col = Int(round(x / spacing)) - 1
        return max(0, min(col, ladderCount - 1))
    }
    
    private func getXPosition(for index: Int, width: CGFloat, count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        let safeIndex = max(0, min(index, count - 1))
        let spacing = width / CGFloat(count + 1)
        return spacing * CGFloat(safeIndex + 1)
    }
    
    private func getYPosition(for index: Int, height: CGFloat, lines: Int) -> CGFloat {
        guard lines > 0 else { return 30 }
        let safeIndex = max(0, min(index, lines - 1))
        let usableHeight = height - 60 // Account for top and bottom circles
        let spacing = usableHeight / CGFloat(lines + 1)
        return 30 + spacing * CGFloat(safeIndex + 1)
    }
}

#Preview {
    LadderGameView()
} 

