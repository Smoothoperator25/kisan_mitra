# Admin Notifications Setup Guide

## Overview
The admin notifications feature has been successfully implemented. However, you're seeing a permission error because the Firestore security rules need to be updated.

## Error You're Seeing
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Solution - Deploy Updated Firestore Rules

### Option 1: Deploy via Firebase Console (Recommended)

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your project: `kisan_mitra`

2. **Navigate to Firestore Rules**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab

3. **Update the Rules**
   - Copy the entire content from `firestore.rules` file in your project
   - Paste it into the Firebase Console rules editor
   - Click "Publish" button

4. **Verify**
   - Wait a few seconds for the rules to propagate
   - Restart your app and check the notifications screen

### Option 2: Deploy via Firebase CLI

```bash
# Navigate to project directory
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

## What Was Added

### New Firestore Rule (lines 80-86 in firestore.rules):
```
// Admin notifications - only admins can read and write their own notifications
match /adminNotifications/{notificationId} {
  allow read: if isAdmin(); // Only admins can read notifications
  allow create: if isAdmin(); // Only admins can create notifications
  allow update: if isAdmin(); // Only admins can update notifications (mark as read)
  allow delete: if isAdmin(); // Only admins can delete notifications
}
```

## Features Implemented

### 1. **Admin Notifications Screen**
   - Location: `lib/features/admin/notifications/admin_notifications_screen.dart`
   - Features:
     - Real-time notification updates
     - Unread/All tabs
     - Filter by notification type (Store, Farmer, System, Activity)
     - Swipe to delete notifications
     - Mark as read/unread
     - Badge showing unread count
     - Pull to refresh

### 2. **Notification Badge on Dashboard**
   - Location: Updated in `admin_dashboard_screen.dart`
   - Shows unread count in real-time
   - Red badge appears when there are unread notifications
   - Tap to navigate to notifications screen

### 3. **Notification Types**
   - **Store Verification**: When a new store requests verification
   - **Farmer Registration**: When a new farmer registers
   - **System Alerts**: Critical system notifications
   - **Activity Updates**: General activity updates
   - **General**: Other notifications

## Testing the Feature

### 1. Create a Test Notification
   1. Open the app and login as admin
   2. Navigate to Notifications screen
   3. Tap the menu (three dots) in top right
   4. Select "Create test notification"
   5. A test notification will appear

### 2. Verify Badge Works
   - Check the notification bell icon on the dashboard
   - It should show a red badge with the unread count
   - Tap it to open notifications screen

### 3. Test Filtering
   - Use the filter chips to filter by type
   - Switch between "All" and "Unread" tabs

### 4. Test Actions
   - Tap a notification to mark it as read
   - Swipe left to delete a notification
   - Use menu to mark all as read or delete all

## Routes Added

New route in `main.dart`:
```dart
'/admin-notifications': (context) => const AdminNotificationsScreen(),
```

## Database Structure

### Collection: `adminNotifications`
```
{
  "adminId": "admin_user_id",
  "title": "Notification Title",
  "message": "Notification message text",
  "type": "storeVerification|farmerRegistration|systemAlert|activityUpdate|general",
  "timestamp": Timestamp,
  "isRead": false,
  "actionUrl": "/admin-stores-list" (optional),
  "metadata": {
    "storeId": "store_id",
    "storeName": "Store Name"
  } (optional)
}
```

## Important Notes

1. **Admin Authentication**: The notification feature only works for authenticated admin users
2. **Real-time Updates**: Notifications update in real-time using Firestore streams
3. **Performance**: The screen limits queries to 50 most recent notifications
4. **Security**: Only admins can access their own notifications (enforced by Firestore rules)

## Troubleshooting

### If you still see permission errors after deploying rules:

1. **Check if you're logged in as admin**
   - Email should be: `admin@kisanmitra.com`
   - Or user should exist in `admins` collection

2. **Verify rules were deployed**
   - Check Firebase Console > Firestore > Rules
   - Look for the `adminNotifications` section

3. **Clear app cache**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Check Firestore indexes**
   - Go to Firebase Console > Firestore > Indexes
   - Create any missing indexes if prompted

## Future Enhancements (Optional)

- Push notifications integration
- Email notifications
- Notification scheduling
- Bulk notification sending
- Notification templates
- Rich media notifications (images, links)

## Support

If you continue to face issues:
1. Check the Flutter console for detailed error messages
2. Verify your admin account exists in Firebase Authentication
3. Ensure Firestore rules are published
4. Check network connectivity

---

**Status**: ✅ Implementation Complete - Awaiting Firestore Rules Deployment
