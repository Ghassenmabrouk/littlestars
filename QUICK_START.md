# QUICK START GUIDE - Get App Running in 5 Minutes

## Step 1: Install Flutter (5 min)

1. **Download Flutter:**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download for Windows
   - Extract to `C:\src\flutter`

2. **Add to PATH:**
   - Open Environment Variables (Win + Pause → Advanced System Settings)
   - Add: `C:\src\flutter\bin`
   - Restart terminal

3. **Verify:**
   ```powershell
   flutter --version
   # Should show version number
   ```

---

## Step 2: Configure API URL (2 min)

1. Open file: `c:\xampp\htdocs\jardin_enfant_flutter_parent\lib\services\api_service.dart`

2. Find this line (around line 6):
   ```dart
   static const String baseUrl = 'http://192.168.1.X:80/jardin_enfant_ghofrane';
   ```

3. Replace `192.168.1.X` with YOUR computer's IP address:
   ```powershell
   # Open PowerShell and run:
   ipconfig
   ```
   Look for "IPv4 Address" under your network adapter

   Example: If you see `192.168.1.105`, change to:
   ```dart
   static const String baseUrl = 'http://192.168.1.105:80/jardin_enfant_ghofrane';
   ```

---

## Step 3: Start Android Emulator (3 min)

1. **Open Android Studio**
2. Click **AVD Manager** (phone icon)
3. Select a virtual device and click **▶ (Play)**
4. Wait for emulator to boot (2-3 minutes)

---

## Step 4: Run Flutter App (2 min)

```powershell
cd c:\xampp\htdocs\jardin_enfant_flutter_parent

# Get dependencies
flutter pub get

# Run app
flutter run
```

**Wait for app to load in emulator (1-2 minutes)...**

---

## Step 5: Test Login

In the app, enter:
- **Login:** (use any username from `utilisateurs` table in your database)
- **Password:** (matching password)

```sql
-- Check available logins:
SELECT login, mot_de_passe FROM utilisateurs LIMIT 5;
```

---

## Common Issues & Quick Fixes

| Problem | Solution |
|---------|----------|
| `Could not connect to server` | Wrong IP address - re-check `ipconfig` |
| `No connected devices` | Open Android Studio and start AVD |
| `pubspec.yaml errors` | Run `flutter clean && flutter pub get` |
| `Module not found error` | Make sure you're in `jardin_enfant_flutter_parent` folder |

---

## IMPORTANT: URL Troubleshooting

### For Emulator:
```dart
// Use this for Android emulator:
static const String baseUrl = 'http://10.0.2.2:80/jardin_enfant_ghofrane';
```

### For Physical Phone (Same WiFi):
```dart
// Use your computer's IP on same WiFi
static const String baseUrl = 'http://192.168.1.105:80/jardin_enfant_ghofrane';
// Change 105 to your IP from ipconfig
```

### Test If API Works:
```powershell
# Replace 192.168.1.105 with YOUR IP
Invoke-RestMethod -Uri "http://192.168.1.105/jardin_enfant_ghofrane/jardin_enfant_ghofrane/api/login" `
  -Method Post `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"login":"admin","password":"password"}'
```

---

## Next Steps After Getting It Running

1. ✅ Create dummy test accounts in `utilisateurs` table
2. ⏳ Create parent-child relationships in `parents` table
3. ⏳ Add attendance records in `presences` table to see data
4. ⏳ Test all screens work

---

**🎉 That's it! Your Flutter app should be running!**

