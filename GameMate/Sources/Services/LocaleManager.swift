import SwiftUI
import Foundation

/// Manager for handling locale-specific settings
class LocaleManager: ObservableObject {
    static let shared = LocaleManager()
    
    // Keys for user defaults
    private let languageKey = "appLanguage"
    
    // Track if initialization is complete
    private var isInitialized = false
    
    // Current language with publisher for SwiftUI updates
    @Published var currentLanguage: String
    
    // The AppStorage that persists the language selection
    @AppStorage("appLanguage") var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "en" {
        didSet {
            // Only update if initialized and actually changed
            if isInitialized && oldValue != appLanguage {
                // Update the published property too
                currentLanguage = appLanguage
                
                // Make sure to always use main thread for UI updates
                DispatchQueue.main.async {
                    // Notify all observers
                    self.objectWillChange.send()
                    
                    // Post notification for app-wide locale change
                    NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
                    
                    // Debug info
                    print("Language changed from \(oldValue) to \(self.appLanguage)")
                }
            }
        }
    }
    
    init() {
        // Initialize the current language with saved value
        self.currentLanguage = UserDefaults.standard.string(forKey: languageKey) ?? 
                              Locale.current.language.languageCode?.identifier ?? "en"
        
        // Debug info during initialization
        print("LocaleManager initialized with language: \(appLanguage)")
        
        // Ensure appLanguage and currentLanguage are in sync
        if appLanguage != currentLanguage {
            appLanguage = currentLanguage
        }
        
        DispatchQueue.main.async {
            self.isInitialized = true
        }
    }
    
    /// The locale influenced by the user's language selection
    var appLocale: Locale {
        Locale(identifier: appLanguage)
    }
    
    /// Sets the app language and updates the environment
    func setAppLanguage(to languageCode: String) {
        guard LocalizationService.shared.availableLanguages().contains(languageCode) else {
            print("Invalid language code: \(languageCode)")
            return
        }
        
        // Only update if it's actually changing
        if appLanguage != languageCode {
            print("Setting language to: \(languageCode)")
            
            // Force UI update on the main thread
            DispatchQueue.main.async {
                // Set the language - this will trigger the didSet
                self.appLanguage = languageCode
                self.currentLanguage = languageCode
                
                // Also update UserDefaults directly to ensure it's saved 
                UserDefaults.standard.set(languageCode, forKey: self.languageKey)
                UserDefaults.standard.synchronize()
                
                // Force update UI
                self.objectWillChange.send()
                
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
                
                // Post an additional notification that might help with UIKit components if any
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "AppleLanguagesDidChange"), 
                    object: nil
                )
            }
        }
    }
} 