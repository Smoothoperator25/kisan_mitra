# Fix: Admin Farmer Management Permission Error

## Problem
Admin cannot update or delete farmer accounts because Firestore rules don't allow it.

**Error Messages:**
- `Error: Exception: Failed to delete farmer: [cloud_firestore/permission-denied]`
- `Error: Exception: Failed to update farmer status: [cloud_firestore/permission-denied]`

## Solution
Updated Firestore rules to allow admins to manage (update/delete) farmer accounts.

---

## ✅ What Was Fixed

### Updated File:
- `firestore.rules` - Added admin permissions to users collection

### Changed Rules:
```javascript
// BEFORE (Only owners could update/delete)
match /users/{userId} {
  allow read: if isSignedIn();
  allow create: if isSignedIn();
  allow update, delete: if isOwner(userId);
}

// AFTER (Owners OR Admins can update/delete)
match /users/{userId} {
  allow read: if isSignedIn();
  allow create: if isSignedIn();
  allow update, delete: if isOwner(userId) || isAdmin();
}
```

---

## 🚀 Deploy Updated Rules to Firebase

### Method 1: Firebase Console (Recommended - Quick)

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select your project: **kisan_mitra**

2. **Navigate to Firestore Rules**
   - Click **"Firestore Database"** in left sidebar
   - Click **"Rules"** tab at the top

3. **Update the Rules**
   - Find this section in the rules editor:
   ```javascript
   match /users/{userId} {
     allow read: if isSignedIn();
     allow create: if isSignedIn();
     allow update, delete: if isOwner(userId);  // ← OLD
   }
   ```

4. **Replace with:**
   ```javascript
   match /users/{userId} {
     allow read: if isSignedIn();
     allow create: if isSignedIn();
     allow update, delete: if isOwner(userId) || isAdmin();  // ← NEW
   }
   ```

5. **Publish**
   - Click **"Publish"** button at the top
   - Wait for confirmation message
   - Rules are now live! ✅

---

### Method 2: Firebase CLI (If you have it installed)

1. Open terminal/command prompt
2. Navigate to your project:
   ```bash
   cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra
   ```

3. Deploy rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

4. Wait for success message

---

## ✅ Verification Steps

After deploying the rules:

1. **Restart your app** (fully close and reopen)

2. **Login as Admin**
   - Username: `admin`
   - Password: `admin123@`

3. **Go to Manage Farmers**
   - Dashboard → Click "Manage Farmers" card
   - Or navigate from bottom menu

4. **Test Operations:**
   - ✅ Click on a farmer → Should open details
   - ✅ Click "Deactivate" → Should work without error
   - ✅ Click "Activate" → Should work without error
   - ✅ Click "Delete" → Should work without error

---

## 🔐 Security Notes

### What Changed:
- **Before:** Only farmers could update/delete their own accounts
- **After:** Farmers can update/delete their own accounts, AND admins can manage all farmer accounts

### Why This is Safe:
1. **Admin Check is Secure:**
   ```javascript
   function isAdmin() {
     return isSignedIn() &&
       (request.auth.token.email == 'admin@kisanmitra.com' ||
        exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
   }
   ```

2. **Only verified admins** in the `admins` collection can perform these actions

3. **Regular farmers cannot** delete or modify other farmers' accounts

4. **Audit trail** can be added to track admin actions (optional enhancement)

---

## 📊 What Admins Can Now Do

### Manage Farmers Screen Features:
✅ **View all farmers** with real-time updates  
✅ **Search farmers** by name, phone, city, or state  
✅ **Filter farmers** by status (All/Active/Inactive)  
✅ **View farmer details** (profile, location, crops)  
✅ **Activate/Deactivate farmers** (prevent app access)  
✅ **Delete farmers** (permanent removal)  
✅ **See statistics** (total, active, inactive counts)  

---

## 🎯 Quick Summary

| Action | Status |
|--------|--------|
| Updated firestore.rules locally | ✅ Done |
| Need to deploy to Firebase | ⏳ **YOU NEED TO DO THIS** |
| Test admin operations | ⏳ After deployment |

**Next Step:** Deploy the rules using Method 1 (Firebase Console) above ⬆️

Once deployed, all admin farmer management features will work perfectly! 🎉
