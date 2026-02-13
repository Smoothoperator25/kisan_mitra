# Admin Dashboard Statistics & Logout Fix

## Summary
Enhanced the admin dashboard to ensure statistics (Total Farmers, Total Stores, Pending, Verified) work correctly and the logout functionality navigates to the admin login screen.

## Changes Made

### 1. Admin Dashboard Controller (`lib/features/admin/dashboard/admin_dashboard_controller.dart`)

#### Improved Statistics Stream
**Before:** Used `Stream.periodic()` which polled Firestore every 2 seconds with multiple separate queries.

**After:** Uses real-time Firestore snapshots for automatic updates:
```dart
Stream<DashboardStats> getStatsStream() {
  return _firestore.collection('stores').snapshots().asyncMap((snapshot) async {
    // Real-time updates when stores collection changes
    // Efficiently counts stats from snapshot data
  });
}
```

#### Added Initial Stats Method
Added a new method for faster initial load:
```dart
Future<DashboardStats> getInitialStats() async {
  // Fetches stats once for initial display
  // Reduces initial load time
}
```

**Benefits:**
- ✅ **Real-time Updates**: Stats update automatically when data changes
- ✅ **Better Performance**: Reduces unnecessary Firestore reads
- ✅ **More Efficient**: Single stream instead of periodic polling
- ✅ **Accurate Counts**: Properly counts pending (not verified AND not rejected) and verified stores

### 2. Logout Functionality

#### Admin Dashboard Screen
The logout already correctly navigates to admin login:
```dart
Future<void> _handleLogout() async {
  // ... confirmation dialog ...
  if (confirm == true) {
    try {
      await _controller.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.adminLoginRoute);
      }
    }
  }
}
```

#### Admin Settings Screen
Also correctly uses `AppConstants.adminLoginRoute`:
```dart
Navigator.pushNamedAndRemoveUntil(
  AppConstants.adminLoginRoute, 
  (route) => false
);
```

## How Statistics Work

### Total Farmers
Counts all documents in the `farmers` collection:
```dart
final farmersSnapshot = await _firestore.collection('farmers').get();
final totalFarmers = farmersSnapshot.size;
```

### Total Stores
Counts all documents in the `stores` collection:
```dart
final totalStores = snapshot.size;
```

### Pending Verifications
Counts stores where:
- `isVerified = false` AND
- `isRejected = false`
```dart
final pendingVerifications = snapshot.docs.where((doc) {
  final data = doc.data();
  final isVerified = data['isVerified'] as bool? ?? false;
  final isRejected = data['isRejected'] as bool? ?? false;
  return !isVerified && !isRejected;
}).length;
```

### Verified Stores
Counts stores where `isVerified = true`:
```dart
final verifiedStores = snapshot.docs.where((doc) {
  final data = doc.data();
  return data['isVerified'] as bool? ?? false;
}).length;
```

## Testing the Statistics

### Step 1: Login as Admin
```
Username: admin
Password: admin123@
```

### Step 2: View Dashboard Statistics
The statistics cards should display:
- **TOTAL FARMERS**: Count of all registered farmers
- **TOTAL STORES**: Count of all registered stores
- **PENDING**: Count of stores awaiting verification
- **VERIFIED**: Count of approved stores

### Step 3: Real-time Updates
The statistics will automatically update when:
- A new store registers
- A store is approved/rejected
- A new farmer registers

### Step 4: Test Logout
1. Click the "Logout" option in Settings section
2. Confirm logout in the dialog
3. **Expected**: Navigate to Admin Login screen (green theme with "ADMIN" title)
4. **Not**: General login/role selection screen

## Troubleshooting

### Statistics Show Zero
**Problem**: All statistics show 0

**Solutions**:
1. Check Firestore console to ensure collections exist
2. Verify `farmers` and `stores` collections have documents
3. Check Firebase Rules allow admin to read these collections

### Statistics Don't Update
**Problem**: Statistics don't update in real-time

**Solutions**:
1. Check internet connection
2. Verify Firestore security rules allow read access
3. Check console for Firestore errors
4. Ensure StreamBuilder is properly connected

### Error Loading Stats
**Problem**: Red error message in statistics area

**Solutions**:
1. Check Firestore indexes are created (see FIRESTORE_INDEX_SETUP.md)
2. Verify Firebase is initialized
3. Check admin has proper permissions in Firestore Rules
4. Look at debug console for specific error messages

## Firebase Rules Required

Ensure your Firestore rules allow admin to read statistics:

```javascript
match /farmers/{farmerId} {
  allow read: if isAdmin() || isAuthenticated();
}

match /stores/{storeId} {
  allow read: if true;  // Or more restrictive with admin check
}

function isAdmin() {
  return isSignedIn() && exists(/databases/$(database)/documents/admins/$(request.auth.uid));
}
```

## Files Modified

1. `lib/features/admin/dashboard/admin_dashboard_controller.dart`
   - Improved `getStatsStream()` to use real-time snapshots
   - Added `getInitialStats()` for faster initial load
   - Fixed efficiency and accuracy of statistics counting

2. `lib/features/admin/dashboard/admin_dashboard_screen.dart`
   - Already correctly uses `AppConstants.adminLoginRoute` for logout
   - No changes needed

3. `lib/features/admin/settings/admin_settings_screen.dart`
   - Already correctly uses `AppConstants.adminLoginRoute` for logout
   - No changes needed

## Benefits

1. **Real-time Statistics**: Dashboard automatically updates when data changes
2. **Better Performance**: Reduced Firestore reads and improved efficiency
3. **Accurate Counts**: Properly distinguishes between pending, verified, and rejected stores
4. **Correct Logout Flow**: Admin always returns to admin login screen
5. **Better User Experience**: Faster initial load with `getInitialStats()`

## Related Documentation

- `ADMIN_LOGOUT_FIX.md` - Previous logout navigation fix
- `FIRESTORE_INDEX_SETUP.md` - Required Firestore indexes
- `ADMIN_TESTING_GUIDE.md` - Complete testing guide
- `FIX_ADMIN_PERMISSION_ERROR.md` - Firestore security rules setup
