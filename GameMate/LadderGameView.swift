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
    
    // Different colors array
    private let colors: [Color] = [
        .red, .blue, .green, .orange, .purple, .pink,
        .yellow, .teal, .indigo, .cyan, .mint, .brown
    ]
    
    var body: some View {
        VStack {
            Text("Ladder Game")
                .font(.largeTitle)
                .padding()
            
            // Ladder count control
            HStack {
                Text("Number of ladders:")
                    .font(.headline)
                Stepper("\(ladderCount)", value: $ladderCount, in: 2...6)
                    .frame(width: 120)
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
                    onStartSelected: { index in
                        tracePath(from: index)
                    }
                )
                .padding()
                .frame(height: 380)
            }
            .padding()
            
            // Show result
            if showResult, let selected = selectedLadder {
                Text("Result: \(selected + 1)")
                    .font(.title)
                    .foregroundColor(colors[selected % colors.count])
                    .padding()
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                // Reset button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        resetGame(generateNewLines: false)
                    }
                }) {
                    Text("Reset")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Shuffle button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        resetGame(generateNewLines: true)
                    }
                }) {
                    Text("Shuffle")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            resetGame(generateNewLines: true)
        }
    }
    
    private func resetGame(generateNewLines: Bool = true) {
        // 상태 초기화
        selectedLadder = nil
        pathPoints = []
        showResult = false
        isAnimating = false
        showHorizontalLines = false 
        
        // 필요한 경우에만 새로운 가로선 생성
        if generateNewLines {
            generateHorizontalLines()
        }
    }
    
    private func generateHorizontalLines() {
        horizontalLines = []
        
        // 사다리의 층수 (높이)
        let ladderHeight = 6
        
        for _ in 0..<ladderHeight {
            var rowLines = [Bool](repeating: false, count: ladderCount - 1)
            
            // 각 층마다 무작위로 가로선 생성
            for i in 0..<ladderCount - 1 {
                // 연속된 가로선 방지
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
    let onStartSelected: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 세로선 그리기
                ForEach(0..<count, id: \.self) { i in
                    let x = self.getXPosition(for: i, in: geometry)
                    
                    VStack {
                        // 시작점 (상단 원)
                        Circle()
                            .fill(colors[i % colors.count])
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                onStartSelected(i)
                            }
                        
                        Spacer()
                    }
                    .position(x: x, y: geometry.size.height / 2)
                    
                    // 세로선
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 30))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height - 30))
                    }
                    .stroke(selectedLadder == nil || selectedLadder == i ? Color.gray : Color.gray.opacity(0.3), lineWidth: 2)
                    
                    VStack {
                        Spacer()
                        
                        // 결과점 (하단 원)
                        Circle()
                            .fill(showResult && selectedLadder != nil ? colors[selectedLadder! % colors.count] : colors[i % colors.count])
                            .frame(width: 30, height: 30)
                    }
                    .position(x: x, y: geometry.size.height / 2)
                }
                
                // 가로선 그리기 - 선택 후에만 보이도록
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
                
                // 선택된 경로 그리기
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
        }
    }
    
    private func getXPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let spacing = geometry.size.width / CGFloat(count + 1)
        return spacing * CGFloat(index + 1)
    }
    
    private func getYPosition(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let usableHeight = geometry.size.height - 60 // 상하단 원의 공간 고려
        let spacing = usableHeight / CGFloat(horizontalLines.count + 1)
        return 30 + spacing * CGFloat(index + 1)
    }
}

extension LadderGameView {
    func tracePath(from startIndex: Int) {
        guard !isAnimating && !showResult else { return }
        guard startIndex >= 0 && startIndex < ladderCount else { return }
        
        isAnimating = true
        selectedLadder = startIndex
        pathPoints = []
        
        // 가로선 보이기
        withAnimation(.easeIn(duration: 0.3)) {
            showHorizontalLines = true
        }
        
        // 잠시 기다린 후 경로 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 현재 위치와 방향 초기화
            var currentCol = startIndex
            var currentRow = 0
            var points: [CGPoint] = []
            
            // 애니메이션 효과를 위한 지연 시간 계산
            let totalSteps = self.horizontalLines.count * 2 // 대략적인 최대 스텝 수
            let animationDuration = 1.5 // 총 애니메이션 시간
            let stepDelay = animationDuration / Double(totalSteps)
            
            // 시작점 추가
            let startPoint = CGPoint(x: self.getXPosition(for: currentCol, width: 300, count: self.ladderCount), y: 30)
            self.pathPoints = [startPoint]
            
            // 경로 따라가기
            self.followPath(currentCol: currentCol, currentRow: currentRow, delay: stepDelay, points: points)
        }
    }
    
    private func followPath(currentCol: Int, currentRow: Int, delay: Double, points: [CGPoint]) {
        // 범위 확인
        guard currentRow >= 0 && currentRow < horizontalLines.count else { return }
        guard currentCol >= 0 && currentCol < ladderCount else { return }
        
        var currentCol = currentCol
        var currentRow = currentRow
        var newPoints = points
        
        // 다음 지점 결정
        let goRight = currentCol < ladderCount - 1 && 
            currentRow < horizontalLines.count && 
            currentCol < horizontalLines[currentRow].count && 
            horizontalLines[currentRow][currentCol]
            
        let goLeft = currentCol > 0 && 
            currentRow < horizontalLines.count && 
            currentCol - 1 < horizontalLines[currentRow].count && 
            horizontalLines[currentRow][currentCol - 1]
        
        let currentX = getXPosition(for: currentCol, width: 300, count: ladderCount)
        let currentY = getYPosition(for: currentRow, height: 380, lines: horizontalLines.count)
        
        if goRight || goLeft {
            // 가로선 따라가기
            let nextX = getXPosition(for: goRight ? currentCol + 1 : currentCol - 1, width: 300, count: ladderCount)
            
            // 가로 이동 추가
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let nextPoint = CGPoint(x: nextX, y: currentY)
                self.pathPoints.append(nextPoint)
                
                // 다음 열로 업데이트
                let nextCol = goRight ? currentCol + 1 : currentCol - 1
                
                // 범위 확인
                if nextCol < 0 || nextCol >= self.ladderCount {
                    self.finishAnimation(at: currentCol)
                    return
                }
                
                // 아래로 한 칸 더 내려가기
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if currentRow + 1 >= self.horizontalLines.count {
                        self.finishAnimation(at: nextCol)
                        return
                    }
                    
                    let nextRowY = self.getYPosition(for: currentRow + 1, height: 380, lines: self.horizontalLines.count)
                    let nextRowPoint = CGPoint(x: nextX, y: nextRowY)
                    self.pathPoints.append(nextRowPoint)
                    
                    // 재귀 호출로 계속 진행
                    self.followPath(currentCol: nextCol, currentRow: currentRow + 1, delay: delay, points: newPoints)
                }
            }
        } else {
            // 가로선 없이 수직 이동
            if currentRow < horizontalLines.count - 1 {
                // 아직 바닥에 도달하지 않음
                let nextY = getYPosition(for: currentRow + 1, height: 380, lines: horizontalLines.count)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let nextPoint = CGPoint(x: currentX, y: nextY)
                    self.pathPoints.append(nextPoint)
                    
                    // 다음 행으로 이동
                    self.followPath(currentCol: currentCol, currentRow: currentRow + 1, delay: delay, points: newPoints)
                }
            } else {
                // 바닥에 도달, 결과 표시
                finishAnimation(at: currentCol)
            }
        }
    }
    
    private func finishAnimation(at finalCol: Int) {
        guard finalCol >= 0 && finalCol < ladderCount else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let finalPoint = CGPoint(x: self.getXPosition(for: finalCol, width: 300, count: self.ladderCount), y: 380 - 30)
            self.pathPoints.append(finalPoint)
            
            // 애니메이션 완료
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.selectedLadder = finalCol
                self.showResult = true
                self.isAnimating = false
            }
        }
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
        let usableHeight = height - 60 // 상하단 원의 공간 고려
        let spacing = usableHeight / CGFloat(lines + 1)
        return 30 + spacing * CGFloat(safeIndex + 1)
    }
}

#Preview {
    LadderGameView()
} 