# Flutter App - Notifications Display Debugging Guide

## Changes Made

I've improved your Flutter app with better error handling and debugging:

### 1. **Enhanced NotificationService** (notification_service.dart)
- ✅ Added detailed console logging to trace the entire flow
- ✅ Better error handling for missing/invalid API responses
- ✅ Logs what data the API returns and how it's being parsed

### 2. **Enhanced NotificationProvider** (notification_provider.dart)
- ✅ Added comprehensive logging at each step
- ✅ Better error messages to identify failures
- ✅ Stack traces for debugging

### 3. **Improved NotificationsScreen** (notifications_screen.dart)
- ✅ Added "Refresh" button when no notifications are available
- ✅ Better logging to track initialization and data updates
- ✅ More detailed console messages

### 4. **Backend Debug Endpoint** (debug_notifications.php)
- ✅ New diagnostic tool to check what notifications exist in database
- ✅ Shows unread messages, unpaid invoices, absent children
- ✅ Useful for verifying data exists before checking the app

---

## Step-by-Step Debugging

### **Step 1: Run Diagnostic on Backend**
Test what notifications should exist for a parent:

```bash
# Replace PARENT_ID with an actual parent ID from your database
http://localhost/jardin_enfant_ghofrane/debug_notifications.php?parent_id=1
```

**What to look for:**
- Check the `summary` → `total_notifications`
- If 0, there are no notifications in the database yet
- If > 0, check `breakdown` to see what types exist

### **Step 2: Check Flutter Console Logs**
Run the app in debug mode and watch the console for:

```
[NotificationsScreen] initState called
[NotificationsScreen] Post frame callback
[NotificationsScreen] Fetching notifications for parent_id: X
[NotificationProvider] Starting fetchNotifications for parent_id: X
[NotificationService] Fetching notifications for parent_id: X
[NotificationService] API Response: {...}
[NotificationProvider] Received N notifications
[NotificationsScreen] Build - isLoading: false, count: N
```

**If you see errors:**
- Look for `[NotificationService] ERROR:` messages
- Check the stack trace below the error
- Copy-paste the full error to understand what's wrong

### **Step 3: Verify API is Working**
Test the API endpoint manually:

```bash
# Using curl
curl "http://localhost/jardin_enfant_ghofrane/notifications_api.php?parent_id=1" \
  -H "Content-Type: application/json"
```

**Expected response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "messages_1234567890",
      "type": "message",
      "title": "New Message",
      "message": "3 new messages",
      "icon": "💬",
      "count": 3,
      "priority": "high",
      "created_at": "2026-05-11T10:30:00+00:00"
    }
  ],
  "count": 1
}
```

---

## Common Issues & Fixes

### **Issue 1: Empty Notifications Array**
**What you'll see:**
```
[NotificationService] Received 0 notifications
[NotificationsScreen] Build - isLoading: false, count: 0
```

**Solution:**
1. Run the debug endpoint to check if data exists
2. If no data exists, create some (send messages, mark children absent, etc.)
3. If data exists but API returns 0, the API queries may be broken

### **Issue 2: API Response Parse Error**
**What you'll see:**
```
[NotificationService] Data is not a list: int
```

**Solution:**
- The API response structure is wrong
- Check if backend API is returning `{ success: true, data: [...] }`
- Compare with expected response format above

### **Issue 3: Connection Error**
**What you'll see:**
```
[NotificationService] ERROR: Connection refused
```

**Solution:**
- Check if backend server is running
- Verify API base URL is correct in app settings
- Check network connectivity

### **Issue 4: Parent ID Not Found**
**What you'll see:**
```
[NotificationsScreen] No user found in auth provider
```

**Solution:**
- You're not logged in properly
- Re-login to the app
- Check AuthProvider has valid user data

---

## Fixing Missing Notifications in Database

If the debug endpoint shows 0 notifications, you need to create some:

### **Add an Unread Message:**
```sql
INSERT INTO messages (sender_id, sender_role, receiver_id, receiver_role, subject, body, created_at)
VALUES (1, 'educateur', 1, 'parent', 'Test Message', 'This is a test', NOW());
```

### **Mark a Child as Absent:**
```sql
UPDATE enfants SET statut = 'absent', updated_at = NOW() WHERE id = 1;
```

### **Create Unpaid Invoice:**
```sql
INSERT INTO paiements (enfant_id, montant, statut, created_at)
VALUES (1, 150.00, 'impayé', NOW());
```

---

## Enable More Detailed Logging

Edit `main.dart` and add this in `main()` before `runApp()`:

```dart
if (!kIsWeb) {
  FirebaseMessaging.instance.enableDebugLogging(true);
}
```

This will show Firebase Messaging details in console.

---

## If Still Not Working

Provide these console logs:

1. Full console output when opening Notifications screen
2. Response from: `debug_notifications.php?parent_id=YOUR_ID`
3. Response from: `notifications_api.php?parent_id=YOUR_ID`

This will help identify exactly where the issue is!

---

## Testing Notifications Work

### **Test 1: Direct API Call**
```bash
curl "http://localhost/jardin_enfant_ghofrane/notifications_api.php?parent_id=1"
```

### **Test 2: Postman/Insomnia**
- Method: GET
- URL: `http://localhost/jardin_enfant_ghofrane/notifications_api.php?parent_id=1`
- Headers: `Content-Type: application/json`

### **Test 3: Browser**
Visit directly:
```
http://localhost/jardin_enfant_ghofrane/notifications_api.php?parent_id=1
```

Should see JSON response in browser.

---

## Summary

✅ **Improved error logging** - Now you can see exactly what's happening
✅ **Better error handling** - No silent failures, all errors are logged
✅ **Debug endpoints** - Tools to check if data exists
✅ **Refresh button** - Can manually refresh notifications
✅ **Console tracing** - Complete flow of data from API to screen

**Next step:** Run the app in debug mode and share the console logs if still not working!
