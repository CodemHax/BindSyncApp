# BindSync

<div align="center">
  <img src="assets/images/logo_bind.png" alt="BindSync Logo" width="150"/>
  
  **A cross-platform chat synchronization app for Discord and Telegram**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📖 Overview

BindSync is a powerful cross-platform messaging application built with Flutter that bridges the gap between Discord and Telegram. It allows users to view, send, and synchronize messages across both platforms in a unified, WhatsApp-like interface with a modern dark theme.

### ✨ Key Features

- 🔄 **Cross-Platform Sync**: Seamlessly synchronize messages between Discord and Telegram
- 📱 **Multi-Platform Support**: Works on Android, iOS, Web, Windows, Linux, and macOS
- 🔐 **Secure Authentication**: Google Sign-In integration via Firebase Authentication
- 💬 **Unified Chat Interface**: View messages from both platforms in one place
- ↩️ **Reply Support**: Reply to messages across platforms
- 🔍 **Message Filtering**: Filter messages by source (Discord/Telegram)
- 🎨 **Modern UI**: WhatsApp-inspired dark theme with smooth animations
- 🔄 **Auto-Refresh**: Automatic message updates in real-time
- 👤 **Customizable**: Set your own username and API endpoint
- ✂️ **Message Actions**: Copy, delete, and reply to messages with swipe gestures

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.0 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Firebase CLI** (optional, for Firebase configuration) - [Install Firebase CLI](https://firebase.google.com/docs/cli)
- **Android Studio** or **Xcode** (for mobile development)
- **Visual Studio** (for Windows development)
- A code editor (**VS Code** or **Android Studio** recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CodemHax/BindSyncApp.git
   cd BindSyncApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   The project includes Firebase configuration files. However, if you want to use your own Firebase project:
   
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Google Sign-In in Authentication settings
   - Download and replace configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
   - Run Firebase CLI to generate `lib/firebase_options.dart`:
     ```bash
     flutterfire configure
     ```

4. **Generate launcher icons** (optional)
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Backend API Setup

BindSync requires a backend API server to synchronize messages between Discord and Telegram. 

1. **First Launch**: When you first open the app, navigate to **Settings** (gear icon)
2. **Configure API URL**: Enter your backend API base URL (e.g., `http://your-api-server.com:8000`)
3. **Set Username**: Choose a display name for your messages
4. **Test Connection**: Use the "Test Connection" button to verify your API server is accessible

### API Server Requirements

Your backend API should implement the following endpoints:

- `GET /messages?limit=100&offset=0` - Retrieve messages
- `POST /messages` - Send a new message
- `DELETE /messages/{id}` - Delete a message
- `GET /health` - Health check endpoint

Expected message format:
```json
{
  "id": "unique-id",
  "source": "telegram" | "discord" | "api",
  "text": "message content",
  "username": "sender name",
  "timestamp": 1234567890.123,
  "tg_msg_id": 123,
  "dc_msg_id": 456,
  "reply_to_id": "parent-message-id",
  "reply_to_tg_id": 123,
  "reply_to_dc_id": 456
}
```

## 📱 Platform-Specific Setup

### Android

1. Minimum SDK version: 21 (Android 5.0)
2. Ensure `android/app/google-services.json` is properly configured
3. Build APK:
   ```bash
   flutter build apk --release
   ```

### iOS

1. Minimum iOS version: 12.0
2. Ensure `ios/Runner/GoogleService-Info.plist` is properly configured
3. Open the iOS project in Xcode and configure signing
4. Build IPA:
   ```bash
   flutter build ios --release
   ```

### Web

1. Firebase configuration is included in the project
2. Build for web:
   ```bash
   flutter build web --release
   ```

### Windows

1. Ensure Visual Studio 2022 or later is installed
2. Build Windows app:
   ```bash
   flutter build windows --release
   ```

### Linux

1. Install required dependencies:
   ```bash
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```
2. Build Linux app:
   ```bash
   flutter build linux --release
   ```

### macOS

1. Minimum macOS version: 10.14
2. Build macOS app:
   ```bash
   flutter build macos --release
   ```

## 🎯 Usage

### Main Features

1. **Login**: Sign in with your Google account
2. **Chat Selection**: Choose between viewing all messages, Telegram only, or Discord only
3. **Send Messages**: Type your message and send it to both platforms simultaneously
4. **Reply to Messages**: Swipe right on any message to reply
5. **Delete Messages**: Swipe left on any message to delete it
6. **Copy Messages**: Long-press to copy message content
7. **Settings**: Configure your username and API server URL

### Navigation

- **Home**: View all synchronized messages
- **Telegram Chat**: View only Telegram messages
- **Discord Chat**: View only Discord messages
- **Settings**: Configure app settings
- **Logout**: Sign out of your account

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── message.dart         # Message data model
├── routes/
│   └── RouteGenrator.dart   # Route management
├── screens/
│   ├── login.dart           # Login screen
│   ├── chat_selection.dart  # Chat selection screen
│   ├── home_page.dart       # All messages view
│   ├── telegram_chat.dart   # Telegram messages view
│   ├── discord_chat.dart    # Discord messages view
│   └── settings.dart        # Settings screen
└── services/
    ├── auth_wrapper.dart          # Authentication wrapper
    ├── api_service.dart           # API communication
    └── user_preferences_service.dart  # Local storage
```

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

## 🛠️ Development

### Code Style

This project follows the official [Flutter style guide](https://docs.flutter.dev/development/tools/formatting). 

Run the linter:
```bash
flutter analyze
```

Format code:
```bash
flutter format .
```

### Debugging

Enable debug mode:
```bash
flutter run --debug
```

View logs:
```bash
flutter logs
```

## 📦 Dependencies

### Main Dependencies

- **flutter**: Flutter SDK
- **firebase_core**: Firebase core functionality
- **firebase_auth**: Firebase authentication
- **google_sign_in**: Google Sign-In integration
- **http**: HTTP client for API calls
- **shared_preferences**: Local storage for user preferences
- **intl**: Internationalization and date formatting
- **flutter_slidable**: Swipeable list items
- **flutter_launcher_icons**: Launcher icon generation

### Dev Dependencies

- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication and backend services
- The open-source community for the various packages used

## 📞 Support

If you encounter any issues or have questions:

- Open an issue on [GitHub](https://github.com/CodemHax/BindSyncApp/issues)
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Review [Firebase documentation](https://firebase.google.com/docs)

## 🗺️ Roadmap

- [ ] Push notifications
- [ ] End-to-end encryption
- [ ] Media file support (images, videos)
- [ ] Message search functionality
- [ ] Dark/Light theme toggle
- [ ] Multiple language support

---

<div align="center">
  Made with ❤️ using Flutter
</div>
