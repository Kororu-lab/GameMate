import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedFilter: LogType? = nil
    
    private var filteredHistory: [LogEntry] {
        if let selectedType = selectedFilter {
            return appModel.history.filter { $0.type == selectedType }
        } else {
            return appModel.history
        }
    }
    
    private var title: String {
        if let filter = selectedFilter {
            return "\(filter.rawValue) History"
        } else {
            return "All History"
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(nil as LogType?)
                ForEach(LogType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type as LogType?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if filteredHistory.isEmpty {
                VStack {
                    Spacer()
                    Text("No history yet")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredHistory) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: iconName(for: entry.type))
                                    .foregroundColor(colorForType(entry.type))
                                
                                Text(entry.result)
                                    .font(.headline)
                            }
                            
                            Text(formatDate(entry.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private func iconName(for type: LogType) -> String {
        switch type {
        case .dice: return "dice"
        case .coin: return "circle.fill"
        case .wheel: return "arrow.clockwise.circle"
        case .arrow: return "arrow.up.circle"
        case .ladder: return "square.grid.3x3"
        }
    }
    
    private func colorForType(_ type: LogType) -> Color {
        switch type {
        case .dice: return .blue
        case .coin: return .yellow
        case .wheel: return .green
        case .arrow: return .red
        case .ladder: return .purple
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppModel())
} 