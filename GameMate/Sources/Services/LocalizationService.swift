import SwiftUI

/// Service responsible for managing app localization
class LocalizationService {
    static let shared = LocalizationService()
    
    /// Returns the current app's language code
    var currentLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    /// Returns the string for the given key in the current language
    func localizedString(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
    
    /// Returns a String.LocalizationValue for the given key
    func localizedStringValue(_ key: String) -> String.LocalizationValue {
        String.LocalizationValue(key)
    }
    
    /// Returns the available languages in the app
    func availableLanguages() -> [String] {
        // Return the list of languages we support
        ["en", "es", "fr", "de", "ja", "ko", "zh-Hans"]
    }
    
    /// Returns the language name for a given language code
    func languageName(for code: String) -> String {
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code) ?? code
    }
} 