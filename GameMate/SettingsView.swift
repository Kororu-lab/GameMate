import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Picker("", selection: $selectedTab) {
                Text("Games").tag(0)
                Text("History").tag(1)
                Text("Appearance").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedTab == 0 {
                GameSelectionView()
                    .padding()
            } else if selectedTab == 1 {
                HistoryView()
                    .padding(.top)
            } else {
                AppearanceSettingsView()
                    .padding()
            }
            
            Spacer()
        }
    }
}

struct GameSelectionView: View {
    @EnvironmentObject private var appModel: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Games (max \(appModel.maxVisibleGames))")
                .font(.headline)
            
            Text("Choose which games appear in the tab bar")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            List {
                ForEach(GameType.allCases) { game in
                    HStack {
                        Image(systemName: game.systemImage)
                            .foregroundColor(gameColor(for: game))
                        
                        Text(game.rawValue)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { appModel.isGameVisible(game) },
                            set: { _ in toggleGame(game) }
                        ))
                    }
                }
            }
            .frame(height: 250)
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
                Text("Dice Settings")
                    .font(.headline)
                
                ColorSelection(
                    title: "Dice Color",
                    useSameColor: $appModel.useSameColorForDice,
                    mainColor: $appModel.diceColor,
                    colorArray: $appModel.diceColors
                )
            }
            
            Divider()
            
            Group {
                Text("Coin Settings")
                    .font(.headline)
                
                ColorSelection(
                    title: "Coin Color",
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
            Toggle("Use same color for all", isOn: $useSameColor)
                .padding(.vertical, 5)
            
            if useSameColor {
                ColorPicker(title, selection: $mainColor)
            } else {
                Text("Multiple colors will be used")
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