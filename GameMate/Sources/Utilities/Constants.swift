import SwiftUI

/// App-wide constants
enum Constants {
    // Animation durations
    enum Animation {
        static let short: Double = 0.1
        static let medium: Double = 0.3
        static let long: Double = 0.5
        static let extraLong: Double = 1.0
    }
    
    // UI constants
    enum UI {
        static let cornerRadius: CGFloat = 10
        static let iconSize: CGFloat = 24
        static let buttonHeight: CGFloat = 50
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }
    
    // Colors
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.orange
        static let accent = Color.purple
        static let background = Color(UIColor.systemBackground)
        static let cardBackground = Color(UIColor.secondarySystemBackground)
    }
    
    // Game-specific constants
    enum Games {
        static let maxDice = 6
        static let maxWheelSections = 12
        static let maxLadderPlayers = 8
    }
} 