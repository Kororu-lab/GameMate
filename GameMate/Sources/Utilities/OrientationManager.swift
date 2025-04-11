import SwiftUI

/// A utility class to manage device orientation throughout the app
class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    /// Lock the orientation to portrait on iPhone, allow all orientations on iPad
    func lockOrientation() {
        if UIDevice.current.userInterfaceIdiom != .pad {
            AppDelegate.lockOrientationToPortrait()
        }
    }
    
    /// Allow device to rotate freely (iPad only)
    func unlockOrientation() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            AppDelegate.allowAllOrientations()
        }
    }
}

// Extension to AppDelegate to provide static orientation control methods
extension AppDelegate {
    static func lockOrientationToPortrait() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
        
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    static func allowAllOrientations() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
        }
        
        UIViewController.attemptRotationToDeviceOrientation()
    }
} 