# Pomodoro Focus App 🍅

A modern, minimalist, and user-friendly Pomodoro focus application built natively for iOS using **SwiftUI** and **SwiftData**. Designed with strict adherence to **Apple Human Interface Guidelines (HIG)**, this app helps you stay focused, manage your tasks, and track your productivity.

## Features ✨

*   **Customizable Timer**: Standard Pomodoro technique built-in (25m Focus, 5m Short Break, 15m Long Break). Fully customizable to fit your workflow.
*   **Task Management**: Plan your focus sessions by writing down your tasks before you start the timer.
*   **Beautiful Statistics**: Visualize your daily and weekly completed Pomodoro sessions using elegant native `SwiftUI Charts`.
*   **Distraction-Free UI**: A clean, minimalist interface with a smooth Circular Progress Bar. Fully supports Dark Mode and Light Mode.
*   **Color Psychology**: 
    *   **Focus Mode**: Warm, energetic pastel red/orange tones.
    *   **Break Mode**: Relaxing, calm pastel green/blue tones.
*   **Smart Alerts**: Local Notifications and sound alerts to keep you on track without needing to constantly check your phone.

## Tech Stack & Architecture 🛠️

*   **Language**: Swift 6
*   **UI Framework**: SwiftUI
*   **Local Storage**: SwiftData
*   **Architecture**: MVVM (Model-View-ViewModel)

### Project Structure

```text
pomodoro/
├── App/           # App entry point and dependency injection
├── Models/        # SwiftData models representing the core business logic
├── ViewModels/    # State management and timer logic
├── Views/         # SwiftUI visual components and screens
└── Core/          # Reusable components, Theme, and Managers
```

## Getting Started 🚀

### Prerequisites
*   macOS 14.0+
*   Xcode 15.0+
*   iOS 17.0+ Target

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pomodoro-ios.git
   ```
2. Open `pomodoro.xcodeproj` in Xcode.
3. Select your target simulator or device.
4. Press `Cmd + R` to build and run the app.

## Contributing 🤝

Contributions, issues, and feature requests are welcome!
Feel free to check [issues page](https://github.com/yourusername/pomodoro-ios/issues) if you want to contribute.

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
