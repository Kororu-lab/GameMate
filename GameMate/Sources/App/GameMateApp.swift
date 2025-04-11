//
//  GameMateApp.swift
//  GameMate
//
//  Created by Chiwoong Hwang on 4/11/25.
//

import SwiftUI

@main
struct GameMateApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var localeManager = LocaleManager.shared
    @State private var refreshView = UUID()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appModel)
                .environment(\.locale, localeManager.appLocale)
                .id(refreshView)  // Forces SwiftUI to recreate the entire view hierarchy
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                    // Force complete app refresh when language changes
                    print("App-wide refresh for language: \(localeManager.appLanguage)")
                    
                    // Generate a new UUID to force complete refresh of the view hierarchy
                    DispatchQueue.main.async {
                        refreshView = UUID()
                    }
                    
                    // Trigger UI refresh
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        localeManager.objectWillChange.send()
                    }
                }
                // Make sure system locale changes are reflected too
                .onChange(of: localeManager.currentLanguage) { _, _ in
                    print("Language changed at app level")
                    refreshView = UUID()
                }
        }
    }
}
