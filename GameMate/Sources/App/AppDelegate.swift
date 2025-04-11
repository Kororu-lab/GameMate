import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set the orientation mask at launch
        configureOrientationRestrictions()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Allow all orientations on iPad, but only portrait on iPhone
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    private func configureOrientationRestrictions() {
        // Force the device to use the orientation mask we define
        if UIDevice.current.userInterfaceIdiom != .pad {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
} 