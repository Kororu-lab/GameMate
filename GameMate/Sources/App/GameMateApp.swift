//
//  GameMateApp.swift
//  GameMate
//
//  Created by Chiwoong Hwang on 4/11/25.
//

import SwiftUI

@main
struct GameMateApp: App {
    // Register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject private var appModel = AppModel()
    @StateObject private var localeManager = LocaleManager.shared
    @State private var refreshView = UUID()
    @State private var showingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
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
                
                // Show splash screen if needed
                if showingSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            // When the splash view signals completion, hide it
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    showingSplash = false
                                }
                            }
                        }
                }
            }
            .onAppear {
                // Lock orientation on app start
                OrientationManager.shared.lockOrientation()
            }
        }
    }
}
