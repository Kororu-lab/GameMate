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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appModel)
        }
    }
}
