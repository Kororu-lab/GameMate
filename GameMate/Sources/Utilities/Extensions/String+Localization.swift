import SwiftUI
import Foundation

extension String {
    /// Returns the localized version of the string with current locale
    var localized: String {
        // Get the current language from LocaleManager
        let languageCode = LocaleManager.shared.appLanguage
        
        // Create a Bundle with this specific language
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let languageBundle = path != nil ? Bundle(path: path!) : Bundle.main
        
        // Use this specific language bundle for localization
        let localizedString = languageBundle?.localizedString(forKey: self, value: self, table: nil) ?? self
        
        if localizedString == self {
            // Fallback to standard localization
            let defaultString = NSLocalizedString(self, bundle: .main, comment: "")
            if defaultString != self {
                return defaultString
            }
            print("Warning: No localization found for '\(self)' in language '\(languageCode)'")
        }
        
        return localizedString
    }
    
    /// Returns the localized value of a string for use in Text views
    var localizedValue: LocalizedStringKey {
        LocalizedStringKey(self)
    }
} 