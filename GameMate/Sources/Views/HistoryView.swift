import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedFilter: LogType?
    @State private var showingDeleteConfirmation = false
    
    init(selectedFilter: LogType? = nil) {
        _selectedFilter = State(initialValue: selectedFilter)
    }
    
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
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if !filteredHistory.isEmpty {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing)
                    .alert(isPresented: $showingDeleteConfirmation) {
                        Alert(
                            title: Text("Delete All History"),
                            message: Text("Are you sure you want to delete all history items? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete All")) {
                                appModel.clearHistory()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
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
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            let entryId = filteredHistory[offset].id
            appModel.deleteHistoryEntry(id: entryId)
        }
    }
    
    private func iconName(for type: LogType) -> String {
        switch type {
        case .dice: return "dice"
        case .coin: return "circle.fill"
        case .wheel: return "arrow.clockwise.circle"
        case .arrow: return "arrow.up.circle"
        }
    }
    
    private func colorForType(_ type: LogType) -> Color {
        switch type {
        case .dice: return .blue
        case .coin: return .yellow
        case .wheel: return .green
        case .arrow: return .red
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