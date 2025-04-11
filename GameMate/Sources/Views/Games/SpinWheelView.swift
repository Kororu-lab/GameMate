import SwiftUI

struct SpinWheelView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var sections: [WheelSection] = []
    @State private var sectionCount: Int = 4
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedSection: WheelSection?
    @State private var isEditingSegments: Bool = false
    @State private var showDebugInfo: Bool = false
    
    init() {
        // Default section count
        _sectionCount = State(initialValue: 4)
    }
    
    var body: some View {
        VStack {
            Text("Spin Wheel".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Section count stepper
            HStack {
                Text(String(format: "Number of sections: %@".localized, String(sectionCount)))
                Spacer()
                Stepper("", value: $sectionCount, in: 2...12)
                    .onChange(of: sectionCount) { _, newValue in
                        updateSections()
                    }
            }
            .padding(.horizontal)
            
            Button(action: {
                isEditingSegments = true
            }) {
                Text("Edit Wheel".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
            .sheet(isPresented: $isEditingSegments) {
                EditSegmentsView(segments: $appModel.wheelSegments)
            }
            
            Spacer()
            
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                
                // Wheel sections
                WheelView(
                    sections: sections,
                    rotation: rotationDegrees
                )
                .frame(width: 300, height: 300)
                
                // Pointer
                WheelTriangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .gray, radius: 1)
                    .position(x: 150, y: 10)
                    .zIndex(10)
                
                // Center circle with spinner icon
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: .gray, radius: 2, x: 0, y: 1)
                    .overlay(
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
                    .zIndex(5)
                    .onTapGesture {
                        if !isSpinning {
                            spinWheel()
                        }
                    }
            }
            .frame(width: 300, height: 300)
            
            Spacer()
            
            if let selectedSection = selectedSection {
                Text(String(format: "Result: %@".localized, selectedSection.text))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            
            if showDebugInfo {
                HStack {
                    Text(String(format: "Current angle: %@°", String(Int(rotationDegrees.truncatingRemainder(dividingBy: 360)))))
                    Spacer()
                    Text(String(format: "Section count: %@", String(sections.count)))
                }
                .font(.caption)
                .padding(.horizontal)
            }
            
            Button(action: spinWheel) {
                Text("Spin Wheel".localized)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSpinning ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isSpinning)
            .padding()
            
            NavigationLink(destination: HistoryView(selectedFilter: .wheel)) {
                Text("View History".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
            
            // Enable debug mode with double tap
            Text("")
                .frame(width: 0, height: 0)
                .onTapGesture(count: 2) {
                    showDebugInfo.toggle()
                }
        }
        .onAppear {
            updateSections()
        }
    }
    
    private func updateSections() {
        // Ensure we have the proper number of segments
        while appModel.wheelSegments.count < sectionCount {
            let newIndex = appModel.wheelSegments.count + 1
            appModel.wheelSegments.append("\(newIndex)")
        }
        
        if appModel.wheelSegments.count > sectionCount {
            appModel.wheelSegments = Array(appModel.wheelSegments.prefix(sectionCount))
        }
        
        // Map segments to sections
        sections = (0..<sectionCount).map { index in
            let colorIndex = index % appModel.wheelColors.count
            let textIndex = index % appModel.wheelSegments.count
            return WheelSection(
                id: index,
                color: appModel.wheelColors[colorIndex],
                text: appModel.wheelSegments[textIndex]
            )
        }
        
        selectedSection = nil
    }
    
    private func spinWheel() {
        guard !isSpinning, !sections.isEmpty else { return }
        
        isSpinning = true
        selectedSection = nil
        
        // Truly random spin - pick a random number of spins (2-5) plus a random ending position
        let spins = Double.random(in: 2...5)
        let randomAngle = Double.random(in: 0..<360)
        let finalRotation = rotationDegrees + (spins * 360) + randomAngle
        
        // Animation duration
        let spinDuration = Double.random(in: 3.0...5.0)
        
        // Start spinning animation
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotationDegrees = finalRotation
        }
        
        // When animation completes, determine the result
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.1) {
            // Calculate which section is at the top
            let normalizedAngle = rotationDegrees.truncatingRemainder(dividingBy: 360)
            let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
            
            // Each section covers (360 / count) degrees
            let degreesPerSection = 360.0 / Double(sections.count)
            
            // The wheel rotates clockwise, so we need to use this calculation to find which section is at top
            let sectionIndex = Int(floor(((360 - positiveAngle).truncatingRemainder(dividingBy: 360)) / degreesPerSection))
            
            // Make sure we have a valid index
            let validSectionIndex = sectionIndex % sections.count
            
            // Set the selected section
            selectedSection = sections[validSectionIndex]
            
            // Log the result
            appModel.addLogEntry(
                type: .wheel,
                result: String(format: "Wheel landed on: %@".localized, sections[validSectionIndex].text)
            )
            
            isSpinning = false
        }
    }
}

struct WheelView: View {
    let sections: [WheelSection]
    let rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(sections) { section in
                SectionView(
                    section: section,
                    totalSections: sections.count,
                    index: getIndex(for: section)
                )
            }
        }
        .rotationEffect(Angle(degrees: rotation))
    }
    
    private func getIndex(for section: WheelSection) -> Int {
        if let index = sections.firstIndex(where: { $0.id == section.id }) {
            return index
        }
        return 0
    }
}

struct SectionView: View {
    let section: WheelSection
    let totalSections: Int
    let index: Int
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let angle = (2 * .pi / Double(totalSections))
            
            // Start drawing sections from the top (pointing upward)
            let startAngle = angle * Double(index) - .pi / 2
            let endAngle = startAngle + angle
            
            Path { path in
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
                path.addLine(to: center)
            }
            .fill(section.color.opacity(0.9))
            .overlay(
                Path { path in
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
                    path.addLine(to: center)
                }
                .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: 1)
            
            // Position text in the middle of each section
            Text(section.text)
                .position(
                    x: center.x + radius * 0.6 * cos(startAngle + angle/2),
                    y: center.y + radius * 0.6 * sin(startAngle + angle/2)
                )
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
        }
    }
}

struct EditSegmentsView: View {
    @Binding var segments: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<segments.count, id: \.self) { index in
                    TextField("Section \(index + 1)".localized, text: $segments[index])
                        .padding(.vertical, 8)
                }
                .onDelete { indexSet in
                    segments.remove(atOffsets: indexSet)
                }
                .onMove { source, destination in
                    segments.move(fromOffsets: source, toOffset: destination)
                }
                
                Button(action: {
                    segments.append("\(segments.count + 1)")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Section".localized)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Wheel Sections".localized)
            .navigationBarItems(
                leading: Button("Cancel".localized) {
                    dismiss()
                },
                trailing: Button("Done".localized) {
                    dismiss()
                }
                .fontWeight(.bold)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

struct WheelSection: Identifiable {
    let id: Int
    let color: Color
    let text: String
}

// Triangle pointer shape
struct WheelTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SpinWheelView()
        .environmentObject(AppModel())
} 
