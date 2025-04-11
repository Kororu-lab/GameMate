# GameMate

A comprehensive iOS game toolkit with multiple useful games and randomization tools.

## Features

- **Dice Roller**: Roll up to 6 dice with physics-based animations
- **Coin Flipper**: Flip customizable coins with realistic animations
- **Spin Wheel**: Create a customizable wheel with up to 12 sections
- **Arrow Spinner**: Random direction spinner with smooth animations
- **Ladder Game**: Randomly connect players to prizes/destinations

## Project Structure

The project follows a clean architecture pattern with the following structure:

```
GameMate/
├── Sources/
│   ├── App/             # Main app files
│   ├── Views/           # UI components organized by feature
│   │   ├── Games/       # Game-specific views
│   │   ├── Settings/    # Settings views
│   │   └── Home/        # Home screen views
│   ├── Shared/          # Reusable components
│   │   ├── Components/  # UI components
│   │   └── Modifiers/   # SwiftUI modifiers
│   ├── Models/          # Data models
│   ├── ViewModels/      # Logic for views
│   ├── Services/        # App services
│   │   ├── Persistence/ # Data storage
│   │   └── Audio/       # Sound effects
│   └── Utilities/       # Extensions and helpers
├── Resources/
│   ├── Assets/          # Images and colors
│   ├── Fonts/           # Custom fonts
│   └── Localization/    # Localized strings
└── Tests/
    ├── UnitTests/       # Logic tests
    └── UITests/         # UI tests
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository
2. Open `GameMate.xcodeproj` in Xcode
3. Build and run the application

## Customization

GameMate is designed to be highly customizable:

- Dice and coin colors can be changed in the settings
- Wheel segments can be added, removed, or reordered
- Games can be hidden or shown based on user preference

## License

This project is available under the MIT license. See the LICENSE file for more info. 