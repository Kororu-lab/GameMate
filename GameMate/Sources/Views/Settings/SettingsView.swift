import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var localeManager = LocaleManager.shared
    @State private var selectedTab = 0
    @State private var showLanguageSettings = false
    
    var body: some View {
        VStack {
            Text("Settings".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Picker("", selection: $selectedTab) {
                Text("Games".localized).tag(0)
                Text("History".localized).tag(1)
                Text("Appearance".localized).tag(2)
                Text("Language".localized).tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedTab == 0 {
                GameSelectionView()
                    .padding()
            } else if selectedTab == 1 {
                HistoryView()
                    .padding(.top)
            } else if selectedTab == 2 {
                AppearanceSettingsView()
                    .padding()
            } else {
                LanguageSettingsView()
                    .padding()
            }
            
            Spacer()
        }
        .id(localeManager.appLanguage) // Force view refresh when language changes
        .environment(\.locale, localeManager.appLocale)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force UI update when language changes
            selectedTab = selectedTab // This forces a state change
        }
    }
}

struct GameSelectionView: View {
    @EnvironmentObject private var appModel: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(String(format: "Select Games (max %@)".localized, String(appModel.maxVisibleGames)))
                .font(.headline)
            
            Text("Choose which games appear in the tab bar".localized)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Single list that handles both selection and order
            List {
                ForEach(appModel.gameOrder, id: \.self) { game in
                    HStack {
                        // Game icon
                        Image(systemName: game.systemImage)
                            .foregroundColor(gameColor(for: game))
                        
                        // Game name
                        Text(game.rawValue.localized)
                        
                        Spacer()
                        
                        // Drag handle
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        // Selection toggle
                        Toggle("", isOn: Binding(
                            get: { appModel.isGameVisible(game) },
                            set: { _ in toggleGame(game) }
                        ))
                    }
                }
                .onMove { indices, destination in
                    appModel.updateGameOrder(from: indices, to: destination)
                }
            }
            .frame(height: 300)
            .environment(\.editMode, .constant(.active))
            
            Text("Drag to reorder games in the tab bar".localized)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
    
    private func toggleGame(_ game: GameType) {
        appModel.toggleGameVisibility(game)
    }
    
    private func gameColor(for game: GameType) -> Color {
        switch game {
        case .dice: return .blue
        case .coin: return .yellow
        case .wheel: return .green
        case .arrow: return .red
        case .ladder: return .purple
        }
    }
}

struct AppearanceSettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("Dice Settings".localized)
                    .font(.headline)
                
                ColorSelection(
                    title: "Dice Color".localized,
                    useSameColor: $appModel.useSameColorForDice,
                    mainColor: $appModel.diceColor,
                    colorArray: $appModel.diceColors
                )
            }
            
            Divider()
            
            Group {
                Text("Coin Settings".localized)
                    .font(.headline)
                
                ColorSelection(
                    title: "Coin Color".localized,
                    useSameColor: $appModel.useSameColorForCoins,
                    mainColor: $appModel.coinColor,
                    colorArray: $appModel.coinColors
                )
            }
        }
    }
}

struct ColorSelection: View {
    let title: String
    @Binding var useSameColor: Bool
    @Binding var mainColor: Color
    @Binding var colorArray: [Color]
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Use same color for all".localized, isOn: $useSameColor)
                .padding(.vertical, 5)
            
            if useSameColor {
                ColorPicker(title, selection: $mainColor)
            } else {
                Text("Multiple colors will be used".localized)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppModel())
} 