# GameMate Localization System

This document explains how the localization system works in GameMate and how to add more translations.

## Overview

GameMate uses Apple's Swift String Catalog system for localization. The primary file is `Localizable.xcstrings`, which contains translations for all UI strings in multiple languages.

Currently supported languages:
- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Japanese (ja)
- Korean (ko)
- Simplified Chinese (zh-Hans)

## How to Use Localized Strings

1. In SwiftUI views, use the `.localized` extension on any string:

```swift
Text("Settings".localized)
```

2. For strings with parameters, use String.format:

```swift
Text(String(format: "Total: %@".localized, String(total)))
```

3. For Text views that need localization, you can also use:

```swift
Text("Settings".localizedValue)
```

## How to Add New Translations

### Adding a New String

1. Open `Localizable.xcstrings`
2. Add a new entry with translations for all supported languages:

```json
"Your New String" : {
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Your New String"
      }
    },
    "es" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Spanish translation"
      }
    },
    // Add translations for all other languages
  }
}
```

### Adding a New Language

1. Open the project settings in Xcode
2. Go to "Info" tab and add a new language in the "Localizations" section
3. Add the new language code to the `availableLanguages()` method in `LocalizationService.swift`
4. Update all string entries in `Localizable.xcstrings` to include the new language

## Architecture

- **LocalizationService**: Central service for managing string lookup and available languages
- **LocaleManager**: Manages the user's selected language and provides it to the app environment
- **String+Localization**: Extension for easy access to localized strings

## Dynamic Language Switching

The app supports dynamic language switching at runtime. When a user selects a new language:

1. The selection is stored in `AppStorage("appLanguage")`
2. `LocaleManager` updates the locale environment
3. Views are automatically refreshed with the new language

## Parameterized Strings

For strings with dynamic values, use the `String(format:)` function:

```swift
let count = 5
String(format: "Number of coins: %@".localized, String(count))
```

## Testing Localization

To test localization:
1. Change the device language in Settings app
2. Use the language selector in the app's Settings screen
3. Use Xcode's localization preview feature 