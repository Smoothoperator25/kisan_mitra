# Admin Dashboard Testing Guide

## Quick Test Steps

### Step 1: Build and Run
```bash
flutter clean
flutter pub get
flutter run
```

### Step 2: Navigate to Admin Login
1. Open the app
2. Wait for splash screen (2 seconds)
3. On Role Selection screen, tap "Admin Login"

### Step 3: Login as Admin
```
Username: admin
Password: admin123@
```

### Step 4: Verify Dashboard Loads

#### ✅ Success Indicators:
- Light blue background (#D4F1F4)
- "Admin Dashboard" header with "SECURE" badge
- Four statistics cards showing:
  - TOTAL FARMERS
  - TOTAL STORES
  - PENDING
  - VERIFIED
- Verification Requests section
- Data Management section
- Settings section
- Bottom navigation with 4 tabs: Dashboard, Requests, Data, Settings

#### ❌ If You See Black Screen:
The app now has error handling. You should see:
- Red error icon
- "Error Loading Dashboard" message
- Specific error details
- "Retry" button
- "Logout" button

### Step 5: Test Navigation
- Tap "REQUESTS" tab (should show pending store verification requests)
- Tap "DATA" tab (should show farmers, stores, fertilizers, reports)
- Tap "SETTINGS" tab (should show admin settings)
- Tap "DASHBOARD" tab (back to main dashboard)

## Common Error Messages & Solutions

### Error: "Permission Denied"
**Solution**: Update Firestore rules to allow admin access
```javascript
// In firestore.rules
match /stores/{storeId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

### Error: "User not found" or "Wrong username/password"
**Solution**: Admin account not created yet
1. Go to Firebase Console > Authentication
2. Add user manually:
   - Email: admin@kisanmitra.com
   - Password: admin123@
3. Or the app will auto-create on first login attempt

### Error: "No pending verification requests"
**Normal behavior**: No stores have registered yet
- This is expected in a fresh install
- Test by creating a store account first

## Testing Full Flow

### 1. Create Test Store
1. Logout from admin
2. Go to Role Selection > "Store Owner"
3. Tap "Register Now"
4. Fill registration form
5. Submit registration

### 2. Verify Store as Admin
1. Login as admin
2. Dashboard should show "1" under PENDING
3. Tap "REQUESTS" tab
4. See the new store registration
5. Tap "APPROVE" or "REJECT"

### 3. Manage Data
1. Tap "DATA" tab
2. View Farmers list
3. View Stores list
4. Manage Fertilizers
5. View Reports

## Debug Mode

### Check Console Output
While the app is running, check terminal for:
```
I/flutter: Dashboard stats loaded: {...}
I/flutter: Verification requests: {...}
```

### Force Errors (for testing error handling)
1. Turn off internet connection
2. Login as admin
3. Should see error screen with retry option

## App State After Fix

### Before Fix:
- Black screen on admin login ❌
- No error messages ❌
- App appears frozen ❌

### After Fix:
- Dashboard loads correctly ✅
- Error screen if something fails ✅
- Retry button to recover ✅
- Logout option always available ✅

## Need Help?

If you still see issues:
1. Check `ADMIN_BLACK_SCREEN_FIX.md` for technical details
2. Look at terminal output for specific errors
3. Verify Firebase configuration
4. Ensure internet connection is active
5. Try on a different device/emulator

## Files Changed in This Fix
- ✅ `lib/main.dart` - Added global providers
- ✅ `lib/features/admin/dashboard/admin_dashboard_screen.dart` - Added error handling
- ✅ All compilation errors fixed
- ✅ Deprecation warnings fixed
