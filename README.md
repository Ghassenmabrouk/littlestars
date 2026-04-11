# Jardin d'Enfant Parent - Flutter Mobile App

A Flutter mobile application for parents to track their children's activities, attendance, and communications at Jardin d'Enfant Ghofrane.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Backend Setup](#backend-setup)
- [Flutter Setup](#flutter-setup)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Features](#features)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### For Backend (CodeIgniter)
- PHP 7.4+ already running (XAMPP)
- MySQL/PostgreSQL database
- CodeIgniter 3.x

### For Flutter
- Flutter SDK 3.0+
- Android Studio (for Android emulator)
- Xcode (for iOS - Mac only)
- VS Code or Android Studio IDE

---

## Backend Setup

### 1. Install Flutter SDK

**Windows:**
```powershell
# Download Flutter from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter (or your preferred location)

# Add Flutter to PATH:
# Open Environment Variables and add: C:\src\flutter\bin

# Verify installation:
flutter doctor
```

### 2. Add REST API to CodeIgniter

The API controller has already been created at:
```
application/modules/jardin_enfant_ghofrane/controllers/Api.php
```

**Available API Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/jardin_enfant_ghofrane/api/login` | Parent login |
| GET | `/jardin_enfant_ghofrane/api/get_children/{user_id}` | Get parent's children |
| GET | `/jardin_enfant_ghofrane/api/get_today_status/{child_id}` | Get today's attendance |
| GET | `/jardin_enfant_ghofrane/api/get_attendance/{child_id}` | Get attendance history |
| GET | `/jardin_enfant_ghofrane/api/get_communications/{child_id}` | Get messages |
| GET | `/jardin_enfant_ghofrane/api/get_activities` | Get activities |
| GET | `/jardin_enfant_ghofrane/api/get_payments/{child_id}` | Get payment info |
| POST | `/jardin_enfant_ghofrane/api/update_fcm_token` | Update push notification token |

### 3. Test API Endpoints

```powershell
# Test login endpoint:
$body = @{
    login = "parent_login"
    password = "password"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost/jardin_enfant_ghofrane/jardin_enfant_ghofrane/api/login" `
  -Method Post `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

---

## Flutter Setup

### 1. Clone/Extract Flutter Project

The Flutter project is located at:
```
c:\xampp\htdocs\jardin_enfant_flutter_parent\
```

### 2. Get Dependencies

```powershell
cd c:\xampp\htdocs\jardin_enfant_flutter_parent
flutter pub get
```

### 3. Configure API URL

**Edit `lib/services/api_service.dart`:**

Find this line and replace with your local IP:
```dart
static const String baseUrl = 'http://192.168.X.X:80/jardin_enfant_ghofrane';
```

**How to find your local IP:**
```powershell
# Windows
ipconfig

# Look for "IPv4 Address" - usually looks like: 192.168.1.100
```

**For Android Emulator:**
If testing on Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:80/jardin_enfant_ghofrane';
```

**For Physical Device:**
```dart
static const String baseUrl = 'http://192.168.1.XXX:80/jardin_enfant_ghofrane';
// Replace XXX with YOUR computer's IP address
```

---

## Configuration

### 1. Enable CORS in CodeIgniter (if needed)

Add to `application/config/config.php` or create a middleware:

```php
// Allow CORS for Flutter app
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header('Access-Control-Allow-Origin: ' . $_SERVER['HTTP_ORIGIN']);
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
}
```

### 2. Firebase Setup (for Push Notifications - Optional)

For now, we've prepared the app structure. Firebase setup requires:

1. Create Firebase project at https://console.firebase.google.com
2. Download `google-services.json` for Android
3. Place in `android/app/`
4. Follow Flutter Firebase docs: https://firebase.flutter.dev

---

## Running the App

### Option 1: Android Emulator

```powershell
# Open Android Studio and create/start an emulator (AVD)

# Then run:
cd c:\xampp\htdocs\jardin_enfant_flutter_parent
flutter run
```

### Option 2: Physical Android Device

```powershell
# Enable USB Debugging on your phone
# Connect phone via USB

# Check connected devices:
flutter devices

# Run app:
flutter run
```

### Option 3: iOS (Mac only)

```bash
cd /path/to/jardin_enfant_flutter_parent
flutter run -d ios
```

### Option 4: Web (Testing Only)

```powershell
flutter run -d chrome
```

---

## Features Implemented

✅ **Parent Login**
- Secure login with credentials
- Session persistence
- Auto-login if credentials saved

✅ **Dashboard**
- Multi-child support
- Today's attendance status
- Child information display

✅ **Quick Actions** (Routes prepared)
- Attendance History
- Communications/Messages
- Activities
- Payments

✅ **API Integration**
- RESTful API calls
- Error handling
- Loading states

⏳ **Coming Soon**
- Firebase Push Notifications
- Detailed screens for each section
- Offline data caching
- UI Improvements

---

## Project Structure

```
jardin_enfant_flutter_parent/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── login_screen.dart     # Login UI
│   │   └── home_screen.dart      # Dashboard
│   ├── models/
│   │   └── models.dart           # Data models
│   ├── services/
│   │   ├── api_service.dart      # API calls
│   │   └── auth_provider.dart    # State management
│   └── widgets/                   # Reusable widgets
├── android/                       # Android native code
├── ios/                          # iOS native code
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

---

## Troubleshooting

### Issue: "Connection refused" or "Failed to connect"

**Solution:**
1. Check your API URL in `lib/services/api_service.dart`
2. Ensure CodeIgniter is running: `localhost/jardin_enfant_ghofrane`
3. Use correct IP address (not localhost for mobile/emulator)
4. Check firewall isn't blocking port 80

### Issue: "Login failed" even with correct credentials

**Solution:**
1. Verify credentials in database: `SELECT * FROM utilisateurs`
2. Check API endpoint is returning JSON
3. Enable debug mode in CodeIgniter to see errors

### Issue: Flutter pub get fails

**Solution:**
```powershell
flutter clean
flutter pub cache clean
flutter pub get
```

### Issue: Emulator slow or not responding

**Solution:**
```powershell
# Start emulator with more resources:
emulator -avd <avd_name> -memory 2048 -dns-server 8.8.8.8
```

---

## Next Steps

1. ✅ Set up and test the app with your credentials
2. ⏳ Implement detailed screens (Attendance, Communications, etc.)
3. ⏳ Add Firebase for push notifications
4. ⏳ Add offline caching with Hive or SQLite
5. ⏳ Build and publish to Play Store / App Store

---

## Support

For questions or issues:
1. Check Flutter documentation: https://flutter.dev/docs
2. Review CodeIgniter docs: https://codeigniter.com/documentation
3. Test API manually with Postman first before debugging app

---

**Happy coding! 🚀**
