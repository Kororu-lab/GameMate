import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var localeManager = LocaleManager.shared
    @State private var refreshToggle = false
    
    var body: some View {
        NavigationView {
            TabView {
                // Dynamic game tabs based on user selection
                ForEach(appModel.getVisibleGames()) { game in
                    gameView(for: game)
                        .tabItem {
                            Label(game.localizedName, systemImage: game.systemImage)
                        }
                }
                
                // Settings tab is always visible
                SettingsView()
                    .tabItem {
                        Label("Settings".localized, systemImage: "gear")
                    }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.locale, localeManager.appLocale)
        .id(localeManager.appLanguage) // Force refresh when language changes
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force refresh by toggling a state value
            refreshToggle.toggle()
            print("MainView refreshing due to language change to: \(localeManager.appLanguage)")
        }
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

