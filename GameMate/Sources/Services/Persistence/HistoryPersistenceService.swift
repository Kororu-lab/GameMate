import Foundation

/// Service responsible for storing and retrieving game history
class HistoryPersistenceService {
    static let shared = HistoryPersistenceService()
    
    private let historyKey = "GameMateHistory"
    
    // Saves history entries to UserDefaults
    func saveHistory(entries: [LogEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    // Retrieves history entries from UserDefaults
    func loadHistory() -> [LogEntry] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode([LogEntry].self, from: data)
        } catch {
            print("Error decoding history: \(error.localizedDescription)")
            return []
        }
    }
    
    // Clears all history entries
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
    
    // Add a single entry to history
    func addEntry(_ entry: LogEntry) {
        var entries = loadHistory()
        entries.insert(entry, at: 0) // Add new entry at the top
        saveHistory(entries: entries)
    }
} 
