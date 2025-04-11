import SwiftUI

enum LogType: String, CaseIterable, Codable {
    case dice = "Dice"
    case coin = "Coin"
    case wheel = "Wheel"
    case arrow = "Arrow"
}

enum GameType: String, CaseIterable, Identifiable, Codable {
    case dice = "Dice"
    case coin = "Coin"
    case wheel = "Wheel"
    case arrow = "Arrow"
    case ladder = "Ladder"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .dice: return "dice"
        case .coin: return "circle.fill"
        case .wheel: return "arrow.clockwise.circle"
        case .arrow: return "arrow.up.circle"
        case .ladder: return "square.grid.3x3"
        }
    }
}

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: LogType
    let result: String
    
    init(type: LogType, result: String) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.result = result
    }
    
    // Implement CodingKeys to ensure proper UUID encoding
    enum CodingKeys: String, CodingKey {
        case id, date, type, result
    }
    
    // Custom init from decoder to properly handle UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        type = try container.decode(LogType.self, forKey: .type)
        result = try container.decode(String.self, forKey: .result)
    }
}

class AppModel: ObservableObject {
    // Game visibility settings
    @Published var visibleGames: Set<GameType> = [.dice, .coin, .wheel, .arrow]
    @Published var maxVisibleGames: Int = 4
    
    // Dice properties
    @Published var diceCount = 1
    @Published var useSameColorForDice = true
    @Published var diceColor = Color.red
    @Published var diceColors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow]
    
    // Coin properties
    @Published var useSameColorForCoins = true
    @Published var coinColor = Color(red: 0.95, green: 0.85, blue: 0.4) // Default gold color
    @Published var coinColors: [Color] = [
        Color(red: 0.95, green: 0.85, blue: 0.4), // Gold
        Color(red: 0.8, green: 0.8, blue: 0.8),   // Silver
        Color(red: 0.85, green: 0.6, blue: 0.3),  // Bronze
        Color(red: 0.6, green: 0.9, blue: 0.6),   // Mint green
        Color(red: 0.6, green: 0.75, blue: 0.9),  // Light blue
        Color(red: 0.9, green: 0.7, blue: 0.9)    // Light purple
    ]
    
    // Wheel properties
    @Published var wheelSegments: [String] = ["1", "2", "3", "4"]
    @Published var wheelColors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow]
    
    // Ladder game properties
    @Published var ladderPlayers: [String] = ["Player 1", "Player 2"]
    @Published var ladderDestinations: [String] = ["Prize 1", "Prize 2"]
    
    // History
    @Published var history: [LogEntry] = []
    
    // Load history on init
    init() {
        loadHistory()
    }
    
    // Load history from persistence service
    func loadHistory() {
        history = HistoryPersistenceService.shared.loadHistory()
    }
    
    func addLogEntry(type: LogType, result: String) {
        let entry = LogEntry(type: type, result: result)
        history.insert(entry, at: 0)
        
        // Also save to persistence service
        HistoryPersistenceService.shared.addEntry(entry)
    }
    
    // Filter history by type
    func filteredHistory(type: LogType?) -> [LogEntry] {
        guard let type = type else {
            return history
        }
        return history.filter { $0.type == type }
    }
    
    // Toggle game visibility
    func toggleGameVisibility(_ game: GameType) {
        if visibleGames.contains(game) {
            visibleGames.remove(game)
        } else if visibleGames.count < maxVisibleGames {
            visibleGames.insert(game)
        }
    }
    
    // Check if a game is visible
    func isGameVisible(_ game: GameType) -> Bool {
        return visibleGames.contains(game)
    }
    
    // Get array of visible games for TabView
    func getVisibleGames() -> [GameType] {
        return GameType.allCases.filter { visibleGames.contains($0) }
    }
    
    // Clear all history
    func clearHistory() {
        history.removeAll()
        HistoryPersistenceService.shared.clearHistory()
    }
    
    // Delete a single history entry
    func deleteHistoryEntry(id: UUID) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history.remove(at: index)
            // Update persistence
            HistoryPersistenceService.shared.saveHistory(entries: history)
        }
    }
} 