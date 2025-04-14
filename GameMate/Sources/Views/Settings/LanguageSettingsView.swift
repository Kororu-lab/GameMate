import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject private var localeManager = LocaleManager.shared
    @State private var refreshToggle = false  // Used to force view refresh
    
    private let localizationService = LocalizationService.shared
    private let languageCodes = LocalizationService.shared.availableLanguages()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Language".localized)
                .font(.headline)
            
            Text("Choose your preferred language".localized)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            List {
                ForEach(languageCodes, id: \.self) { code in
                    HStack {
                        // Get language name in its own language
                        Text(localizationService.languageName(for: code))
                            .foregroundStyle(Color.primary)
                        
                        Spacer()
                        
                        // Show checkmark for current language
                        if localeManager.appLanguage == code {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Update the language through LocaleManager
                        print("Language selected: \(code)")
                        localeManager.setAppLanguage(to: code)
                        refreshToggle.toggle()
                    }
                }
            }
            .frame(height: 300)
            .id(refreshToggle) // Force view to redraw when this changes
        }
        .padding()
        .id(localeManager.currentLanguage) // Force view refresh when language changes
        .environment(\.locale, localeManager.appLocale)
        .onAppear {
            // Print debug info when view appears
            print("Current language in settings view: \(localeManager.appLanguage)")
            print("Available languages: \(languageCodes)")
        }
    }
} 