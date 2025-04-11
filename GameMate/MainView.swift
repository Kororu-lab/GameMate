import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appModel: AppModel
    
    var body: some View {
        NavigationView {
            TabView {
                // Dynamic game tabs based on user selection
                ForEach(appModel.getVisibleGames()) { game in
                    gameView(for: game)
                        .tabItem {
                            Label(game.rawValue, systemImage: game.systemImage)
                        }
                }
                
                // Settings tab is always visible
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .dice:
            DiceView()
        case .coin:
            CoinView()
        case .wheel:
            SpinWheelView()
        case .arrow:
            ArrowSpinnerView()
        case .ladder:
            LadderGameView()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppModel())
} 