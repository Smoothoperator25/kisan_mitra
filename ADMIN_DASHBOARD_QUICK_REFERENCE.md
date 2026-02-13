# Admin Dashboard - Quick Reference

## ✅ What's Working Now

### 1. Statistics Display
All four statistics cards are fully functional:
- **TOTAL FARMERS**: Real-time count from `farmers` collection
- **TOTAL STORES**: Real-time count from `stores` collection  
- **PENDING**: Stores waiting for verification (not verified AND not rejected)
- **VERIFIED**: Approved stores

### 2. Logout Flow
✅ Admin → Logout → **Admin Login Screen** (correct)
❌ NOT → General Login/Role Selection Screen

### 3. Fix Database Tool
🔧 **NEW**: Wrench icon in dashboard header to fix missing store fields

## ⚠️ If Statistics Show 0 or Don't Update

### Quick Fix (30 seconds):
1. Login as admin
2. Look for the **wrench icon (🔧)** in the top-right of dashboard
3. Click the wrench icon
4. Click "Fix Database" button
5. Wait for success message
6. ✅ Statistics should now show correct counts!

**What this does:** Adds missing `isVerified` and `isRejected` fields to all stores in your database.

**When to use:** If statistics show 0 or don't update after approving/rejecting stores.

## How It Works

### Real-time Statistics
The dashboard uses Firestore snapshots for automatic updates:

```dart
StreamBuilder<DashboardStats>(
  stream: _controller.getStatsStream(),
  builder: (context, snapshot) {
    // Shows loading, error, or stats
  },
)
```

**When do stats update?**
- Automatically when any store is added/verified/rejected
- When a new farmer registers
- No need to refresh the page

### Logout Process
```
Admin clicks Logout
    ↓
Confirmation Dialog
    ↓
Calls _controller.logout() (Firebase signOut)
    ↓
Navigator.pushReplacementNamed(context, AppConstants.adminLoginRoute)
    ↓
Admin Login Screen ✓
```

## Testing Checklist

### First Time Setup (if stats show 0):
- [ ] Login as admin
- [ ] Click wrench icon (🔧) in dashboard header
- [ ] Click "Fix Database" button
- [ ] Wait for success message

### Statistics
- [ ] Open admin dashboard
- [ ] All 4 cards show numbers (not error or loading forever)
- [ ] Numbers match actual data in Firestore
- [ ] Stats update when you approve/reject a store
- [ ] No errors in debug console

### Logout
- [ ] Click "Logout" in Settings section
- [ ] Confirm in dialog
- [ ] Lands on Admin Login screen (green theme, "ADMIN" title)
- [ ] Can login again with admin/admin123@

## Common Issues & Fixes

### "Error loading stats"
**Cause**: Firestore permission or connection issue
**Fix**: 
1. Check Firestore rules allow admin to read `farmers` and `stores`
2. Verify internet connection
3. Check Firebase is initialized

### Stats show 0 but data exists
**Cause**: Collection names might be different
**Fix**:
1. Open Firestore console
2. Verify collections are named exactly: `farmers` and `stores`
3. Check documents have `isVerified` and `isRejected` boolean fields

### Logout goes to wrong screen
**Cause**: Already fixed! Should not happen.
**Fix**: Verify you're using the updated code with `AppConstants.adminLoginRoute`

## Code Locations

### Statistics Logic
📁 `lib/features/admin/dashboard/admin_dashboard_controller.dart`
- Method: `getStatsStream()` - Real-time updates
- Method: `getInitialStats()` - Initial load

### Logout Logic
📁 `lib/features/admin/dashboard/admin_dashboard_screen.dart`
- Method: `_handleLogout()` - Line ~119-140

📁 `lib/features/admin/settings/admin_settings_screen.dart`
- Logout button section - Line ~512

### Data Models
📁 `lib/features/admin/dashboard/admin_dashboard_model.dart`
- Class: `DashboardStats` - Holds the 4 statistics

## Admin Login Credentials
```
Username: admin
Password: admin123@
```

## Quick Commands

```bash
# Run the app
flutter run

# Check for errors
flutter analyze

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# View logs
flutter logs
```

## What Changed?

### Before
- Statistics used polling (checked every 2 seconds)
- Multiple separate Firestore queries
- Less efficient

### After  
- Statistics use real-time snapshots
- Single stream with automatic updates
- More efficient and responsive
- Added initial stats method for faster load

## Need Help?

See detailed documentation:
- `ADMIN_DASHBOARD_STATS_FIX.md` - Complete technical details
- `ADMIN_TESTING_GUIDE.md` - Full testing guide
- `ADMIN_LOGOUT_FIX.md` - Logout navigation details
