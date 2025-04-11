import SwiftUI

struct SpinWheelView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var sections: [WheelSection] = []
    @State private var sectionCount: Int = 4
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedSection: WheelSection?
    @State private var isEditingSegments: Bool = false
    
    init() {
        // Default section count
        _sectionCount = State(initialValue: 4)
    }
    
    var body: some View {
        VStack {
            Text("Spin Wheel")
                .font(.largeTitle)
                .padding()
            
            // Section count stepper
            HStack {
                Text("Number of sections:")
                Stepper("\(sectionCount)", value: $sectionCount, in: 2...12)
                    .frame(width: 150)
                    .onChange(of: sectionCount) { _, newValue in
                        updateSections()
                    }
            }
            .padding(.horizontal)
            
            Button("Edit Wheel") {
                isEditingSegments = true
            }
            .padding(.bottom)
            .sheet(isPresented: $isEditingSegments) {
                EditSegmentsView(segments: $appModel.wheelSegments)
            }
            
            ZStack {
                // Wheel
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .overlay(
                        ForEach(sections) { section in
                            WheelSectionView(
                                section: section,
                                totalSections: sections.count,
                                index: getIndex(for: section)
                            )
                        }
                        .rotationEffect(Angle(degrees: rotationDegrees))
                    )
                
                // Pointer
                WheelTriangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .gray, radius: 1)
                    .position(x: 150, y: 10)
                
                // Center circle with spinner icon
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: .gray, radius: 2, x: 0, y: 1)
                    .overlay(
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    )
                    .onTapGesture {
                        if !isSpinning {
                            spinWheel()
                        }
                    }
            }
            .frame(width: 300, height: 300)
            
            if let selectedSection = selectedSection {
                Text("Result: \(selectedSection.text)")
                    .font(.title2)
                    .padding()
            }
            
            Button(action: {
                if !isSpinning {
                    spinWheel()
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
    
    private func getIndex(for section: WheelSection) -> Int {
        if let index = sections.firstIndex(where: { $0.id == section.id }) {
            return index
        }
        return 0
    }
    
    private func spinWheel() {
        isSpinning = true
        selectedSection = nil
        
        // Random spin between 2 to 5 full rotations (720 to 1800 degrees)
        let spinDuration = Double.random(in: 2.0...5.0)
        let rotation = Double.random(in: 720...1800)
        let finalAngle = rotationDegrees + rotation
        
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotationDegrees = finalAngle
        }
        
        // When spin completes, determine the winning section
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {
            determineSelectedSection(finalAngle: finalAngle)
            isSpinning = false
        }
    }
    
    private func determineSelectedSection(finalAngle: Double) {
        // Normalize the angle to 0-360
        let normalizedAngle = finalAngle.truncatingRemainder(dividingBy: 360)
        
        // Convert to 0-360 range
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
        
        // Calculate which section the pointer is pointing at
        let degreesPerSection = 360.0 / Double(sections.count)
        let sectionIndex = Int((positiveAngle / degreesPerSection).rounded()) % sections.count
        
        selectedSection = sections[sectionIndex]
        
        // Log the result
        if let selected = selectedSection {
            appModel.addLogEntry(
                type: .wheel,
                result: "Wheel landed on: \(selected.text)"
            )
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
                    TextField("Section \(index + 1)", text: $segments[index])
                }
                .onDelete { indexSet in
                    segments.remove(atOffsets: indexSet)
                }
                .onMove { source, destination in
                    segments.move(fromOffsets: source, toOffset: destination)
                }
                
                Button("Add Section") {
                    segments.append("\(segments.count + 1)")
                }
            }
            .navigationTitle("Edit Wheel Sections")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    dismiss()
                }
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

struct WheelSectionView: View {
    let section: WheelSection
    let totalSections: Int
    let index: Int
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let angle = (2 * .pi / Double(totalSections))
            let startAngle = angle * Double(index)
            let endAngle = startAngle + angle
            
            Path { path in
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
                path.addLine(to: center)
            }
            .fill(section.color)
            .overlay(
                Path { path in
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
                    path.addLine(to: center)
                }
                .stroke(Color.white, lineWidth: 1)
            )
            
            // Section text
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
        }
    }
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