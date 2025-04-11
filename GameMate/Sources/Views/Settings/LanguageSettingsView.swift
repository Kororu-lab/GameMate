import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localeManager = LocaleManager.shared
    @State private var refreshToggle = false  // Used to force view refresh
    
    private let localizationService = LocalizationService.shared
    private let languageCodes = LocalizationService.shared.availableLanguages()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(languageCodes, id: \.self) { code in
                    Button {
                        // Update the language through LocaleManager
                        print("Button pressed for language: \(code)")
                        
                        // Update the language
                        localeManager.setAppLanguage(to: code)
                        
                        // Toggle state to force refresh
                        refreshToggle.toggle()
                    } label: {
                        HStack {
                            // Get language name in its own language (when possible)
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
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done".localized)
                    }
                }
            }
            .id(refreshToggle) // Force view to redraw when this changes
        }
        .id(localeManager.currentLanguage) // Force view refresh when language changes
        .environment(\.locale, localeManager.appLocale)
        .onAppear {
            // Print debug info when view appears
            print("Current language in settings view: \(localeManager.appLanguage)")
            print("Available languages: \(languageCodes)")
        }
    }
} 