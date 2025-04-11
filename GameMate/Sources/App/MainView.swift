import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var localeManager = LocaleManager.shared
    @State private var refreshToggle = false
    @State private var selectedTab = 0  // Track the selected tab
    @AppStorage("lastSelectedTab") private var lastSelectedTab = 0  // Persist between app launches
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {  // Add selection binding
                // Dynamic game tabs based on user selection
                ForEach(Array(appModel.getVisibleGames().enumerated()), id: \.element) { index, game in
                    gameView(for: game)
                        .tabItem {
                            Label(game.localizedName, systemImage: game.systemImage)
                        }
                        .tag(index)  // Use index as the tag
                }
                
                // Settings tab is always visible
                SettingsView()
                    .tabItem {
                        Label("Settings".localized, systemImage: "gear")
                    }
                    .tag(appModel.getVisibleGames().count)  // Settings is always the last tab
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.locale, localeManager.appLocale)
        .id("\(localeManager.appLanguage)-\(refreshToggle)") // Force refresh when language changes or tab order changes
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force refresh by toggling a state value
            refreshToggle.toggle()
            print("MainView refreshing due to language change to: \(localeManager.appLanguage)")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameOrderChanged"))) { notification in
            // Force refresh when game order changes
            refreshToggle.toggle()
            
            // Check if the change came from settings screen
            if let source = notification.userInfo?["source"] as? String, source == "settings" {
                // If from settings, maintain the settings tab selection
                selectedTab = appModel.getVisibleGames().count
                print("MainView refreshing due to settings change, staying on settings tab")
            } else {
                print("MainView refreshing due to game order change, maintaining tab \(selectedTab)")
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            // Save the selected tab
            lastSelectedTab = newValue
        }
        .onAppear {
            // Restore tab selection, but ensure it's valid
            let visibleCount = appModel.getVisibleGames().count
            if lastSelectedTab <= visibleCount {
                selectedTab = lastSelectedTab
            }
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

