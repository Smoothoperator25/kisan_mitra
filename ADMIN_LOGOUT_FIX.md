# Admin Logout Navigation Fix

## Problem
When the admin logged out from the Settings screen, the app was navigating to the general login screen (`/login`) instead of the admin login screen (`/admin-login`).

## Solution
Updated the admin logout functionality to properly navigate to the admin login screen.

## Changes Made

### 1. Admin Settings Screen (`lib/features/admin/settings/admin_settings_screen.dart`)

#### Added Import:
```dart
import '../../../core/constants/app_constants.dart';
```

#### Updated Logout Navigation:
Changed from:
```dart
Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
```

To:
```dart
Navigator.of(context).pushNamedAndRemoveUntil(AppConstants.adminLoginRoute, (route) => false);
```

### 2. Admin Dashboard Screen (`lib/features/admin/dashboard/admin_dashboard_screen.dart`)

#### Added Import:
```dart
import '../../../core/constants/app_constants.dart';
```

#### Updated Logout Navigation:
Changed from hardcoded route:
```dart
Navigator.pushReplacementNamed(context, '/admin-login');
```

To using constant:
```dart
Navigator.pushReplacementNamed(context, AppConstants.adminLoginRoute);
```

## Benefits

1. **Consistent Navigation**: Admin always goes to the admin login screen after logout
2. **Better Code Maintainability**: Using constants instead of hardcoded strings
3. **Type Safety**: Route names defined in one place (`AppConstants`)
4. **Better UX**: Admin users won't be confused by landing on the wrong login screen

## Testing

1. Login as admin:
   - Username: `admin`
   - Password: `admin123@`

2. Navigate to Settings tab

3. Click "Logout Account" button

4. Confirm logout

5. **Expected Result**: You should be redirected to the Admin Login screen (with the admin username field and green theme)

6. **Previous Behavior**: Was redirected to the general login screen (role selection screen)

## Related Files

- `lib/features/admin/settings/admin_settings_screen.dart` - Settings screen with logout button
- `lib/features/admin/dashboard/admin_dashboard_screen.dart` - Dashboard screen with logout option
- `lib/features/admin/dashboard/admin_dashboard_screen_minimal.dart` - Already had correct implementation
- `lib/core/constants/app_constants.dart` - Contains route constants

## Notes

The minimal admin dashboard screen already had the correct implementation using `AppConstants.adminLoginRoute`, which is now consistent across all admin screens.
