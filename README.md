# PlayBaloot - Flutter Game Room Manager

![PlayBaloot Logo](assets/Icons/LoGoBaloot.png)

## 🎮 About PlayBaloot

PlayBaloot is a comprehensive digital platform designed to enhance the traditional Middle Eastern card game experience of Baloot. This application brings the classic game into the digital age with modern features while preserving the cultural essence of the game.

### 🌟 Project Vision
PlayBaloot aims to create a seamless and engaging experience for Baloot enthusiasts by providing a digital platform that makes it easy to play with friends and family, regardless of physical distance. The app combines traditional gameplay with modern technology to create an accessible and enjoyable experience for players of all skill levels.

### 🎯 Key Objectives
- **Preserve Tradition**: Maintain the authentic rules and spirit of traditional Baloot
- **Enhance Accessibility**: Make the game accessible to players worldwide
- **Simplify Gameplay**: Streamline the scoring and game management process
- **Foster Community**: Create a platform for Baloot enthusiasts to connect and play
- **Modern Experience**: Combine traditional gameplay with modern UI/UX principles

### 🃏 Game Overview
Baloot is a popular trick-taking card game played in the Middle East, particularly in Saudi Arabia, Kuwait, and other Gulf countries. It's typically played by four players in two partnerships with a standard deck of 32 cards. The game involves bidding, strategic card play, and careful score tracking.

### 📱 Digital Transformation
This app transforms the traditional card game experience by:
- Eliminating the need for physical cards and scorekeeping
- Providing real-time score calculations
- Enabling remote play with friends
- Offering interactive tutorials for new players
- Maintaining game statistics and history

With PlayBaloot, players can enjoy the game anytime, anywhere, with all the traditional elements preserved in a modern, user-friendly interface.

## 🚀 Features

- **User Authentication**: Secure sign-in using Firebase Authentication
- **Game Room Management**: Create and join game rooms with unique QR codes
- **Real-time Updates**: Live score tracking using Firebase Realtime Database
- **Responsive UI**: Beautiful and intuitive interface that works on multiple screen sizes
- **Multiplayer Support**: Play with friends in real-time
- **Animations & Effects**: Engaging user experience with smooth animations
- **Multi-language Support**: Supports multiple languages through localization
- **Dark/Light Mode**: Automatic theme adaptation based on system settings

## 📱 Screenshots

*(Screenshots will be added here)*

## 🛠️ Tech Stack

- **Framework**: Flutter 3.7.0+
- **State Management**: Flutter Bloc (Cubit)
- **Backend**: Firebase (Authentication, Firestore, Realtime Database)
- **Localization**: Flutter Localization
- **UI Components**: Custom widgets with responsive design
- **Animation**: Lottie, Rive, and Flare
- **QR Code**: QR code generation and scanning
- **Push Notifications**: OneSignal integration

## 📂 Project Structure

```
lib/
├── data/                 # Data layer
│   └── room.repo.dart    # Room repository for data operations
├── src/
│   ├── core/             # Core functionality
│   │   └── cubit/        # Application-wide cubits
│   └── features/         # Feature-based modules
│       ├── create/       # Room creation feature
│       ├── home/         # Home screen
│       ├── intros/       # App introduction screens
│       ├── join/         # Join room feature
│       ├── room/         # Game room functionality
│       └── splash/       # Splash screen
├── widgets/              # Reusable widgets
└── main.dart             # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (2.19.0 or higher)
- Android Studio / Xcode (for emulator/simulator)
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/playbaloot.git
   cd playbaloot
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create a new project in the [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Place these files in their respective platform folders

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
FIREBASE_API_KEY=your_firebase_api_key
ONESIGNAL_APP_ID=your_onesignal_app_id
```

### Firebase Setup

1. Enable the following services in Firebase Console:
   - Authentication (Email/Password)
   - Firestore Database
   - Realtime Database
   - Storage (if using file uploads)

## 🎨 Theming

The app uses a custom theme defined in `lib/src/core/theme/`. You can modify colors, text styles, and other theming properties here.

## 📝 Code Style

This project follows the [official Flutter style guide](https://dart.dev/guides/language/effective-dart/style).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- The Baloot community for keeping this wonderful game alive

## 📧 Contact

For any questions or feedback, please contact [your-email@example.com]
