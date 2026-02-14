# Fix: Terms & Privacy Policy Permission Error ✅

## 🐛 Problem

When opening **Admin Settings → Terms & Privacy Policy**, you get this error:

```
Error loading documents: [cloud_firestore/permission-denied] 
The caller does not have permission to execute the specified operation.
```

**Root Cause:** Firestore rules don't have permissions defined for the `legalDocuments` collection.

---

## ✅ Solution: Update Firestore Rules

### Method 1: Firebase Console (Recommended - Quick & Easy)

#### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com**
2. Select your project: **kisan_mitra**

#### Step 2: Navigate to Firestore Rules

1. Click **"Firestore Database"** in the left sidebar
2. Click **"Rules"** tab at the top

#### Step 3: Add Missing Rules

Find this section at the bottom of your rules (around line 84):

```javascript
    // Admin notifications - only admins can read and write their own notifications
    match /adminNotifications/{notificationId} {
      allow read: if isAdmin();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
  }
}
```

**Replace it with:**

```javascript
    // Admin notifications - only admins can read and write their own notifications
    match /adminNotifications/{notificationId} {
      allow read: if isAdmin();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // Legal documents (Terms & Privacy) - public read, admin write
    match /legalDocuments/{docId} {
      allow read: if true; // Everyone can read terms and privacy policy
      allow write: if isAdmin(); // Only admins can update legal documents
    }

    // Roles collection - only admins can read and write
    match /roles/{roleId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }

    // Store users collection - only admins can read and write
    match /storeUsers/{userId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
  }
}
```

#### Step 4: Publish the Rules

1. Click the **"Publish"** button (top right)
2. Wait for "Rules published successfully" message
3. Note the "Last published" timestamp

---

### Method 2: Using Firebase CLI (Alternative)

If you have Firebase CLI installed:

```powershell
# Navigate to project directory
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Deploy only Firestore rules
firebase deploy --only firestore:rules
```

**Note:** The rules have already been updated in the local `firestore.rules` file.

---

## 🔍 What These Rules Do

### 1. Legal Documents (`legalDocuments` collection)
```javascript
match /legalDocuments/{docId} {
  allow read: if true;        // ✅ Anyone can read (for displaying in app)
  allow write: if isAdmin();  // ✅ Only admins can edit Terms & Privacy
}
```

**Why?**
- Farmers and stores need to read Terms & Privacy in the app
- Only admins should be able to update these legal documents

### 2. Roles (`roles` collection)
```javascript
match /roles/{roleId} {
  allow read: if isAdmin();   // ✅ Only admins can view roles
  allow write: if isAdmin();  // ✅ Only admins can manage roles
}
```

**Used by:** Security & Access Control screen

### 3. Store Users (`storeUsers` collection)
```javascript
match /storeUsers/{userId} {
  allow read: if isAdmin();   // ✅ Only admins can view store users
  allow write: if isAdmin();  // ✅ Only admins can manage store users
}
```

**Used by:** User Access Control screen

---

## 🧪 Testing After Update

### 1. Verify Rules Are Published
1. Open Firebase Console
2. Go to **Firestore Database → Rules**
3. Check "Last published" timestamp (should be recent)

### 2. Test the Screen
1. **Completely close and restart your app** (not just hot reload)
2. Login as admin: `admin@kisanmitra.com`
3. Go to: **Admin Dashboard → Settings → Terms & Privacy Policy**
4. ✅ Screen should load without errors
5. ✅ You should see two tabs: "Terms of Service" and "Privacy Policy"

### 3. Test Functionality
1. Click on **"Terms of Service"** tab
2. Type some content in the text field
3. Click **"Save Changes"** button
4. ✅ Should show: "Documents saved successfully" (green snackbar)

---

## 🔐 Security Summary

### What's Protected:

| Collection | Read Access | Write Access |
|-----------|-------------|--------------|
| `legalDocuments` | ✅ Everyone | 🔒 Admins only |
| `roles` | 🔒 Admins only | 🔒 Admins only |
| `storeUsers` | 🔒 Admins only | 🔒 Admins only |
| `adminNotifications` | 🔒 Admins only | 🔒 Admins only |
| `adminUsers` | 🔒 Admins only | 🔒 Admins only |
| `appConfig` | 🔒 Admins only | 🔒 Admins only |
| `adminActivityLogs` | 🔒 Admins only | 🔒 Admins only |

### Who is an Admin?

The `isAdmin()` function checks:
```javascript
function isAdmin() {
  return isSignedIn() &&
    (request.auth.token.email == 'admin@kisanmitra.com' ||
     exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
}
```

✅ User with email `admin@kisanmitra.com`  
✅ OR any user who has a document in the `admins` collection

---

## 🐛 Troubleshooting

### Still Getting Permission Denied?

#### Check 1: Rules Published?
- Go to Firebase Console → Firestore → Rules
- Look for "Last published" timestamp
- Should be recent (within last few minutes)

#### Check 2: Logged in as Admin?
- Make sure you're logged in as `admin@kisanmitra.com`
- Or verify your user ID exists in `admins` collection

#### Check 3: Restart App
- **Completely close the app** (don't just hot reload)
- Reopen and try again
- Firestore might cache old rules

#### Check 4: Admin Document Exists
1. Go to Firebase Console
2. Click **Firestore Database → Data**
3. Look for `admins` collection
4. Verify your admin UID is there

### How to Create Admin Document

If admin document doesn't exist:

1. Go to Firebase Console → Firestore Database → Data
2. Click **"Start collection"**
3. Collection ID: `admins`
4. Document ID: `your_admin_uid` (get from Firebase Authentication)
5. Add fields:
   ```
   email: "admin@kisanmitra.com"
   createdAt: (timestamp) 
   ```
6. Click **"Save"**

---

## 📋 Complete Updated Rules File

The complete `firestore.rules` file now has **11 collection rules**:

1. ✅ `users` - Farmers
2. ✅ `stores` - Store information
3. ✅ `admins` - Admin users
4. ✅ `fertilizers` - Fertilizer master data
5. ✅ `store_fertilizers` - Store inventory
6. ✅ `safety_guidelines` - Safety tips
7. ✅ `adminActivityLogs` - Admin actions log
8. ✅ `appConfig` - App configuration
9. ✅ `adminUsers` - Admin user management
10. ✅ `adminNotifications` - Admin notifications
11. ✅ **`legalDocuments`** - Terms & Privacy ← **NEWLY ADDED**
12. ✅ **`roles`** - User roles ← **NEWLY ADDED**
13. ✅ **`storeUsers`** - Store user management ← **NEWLY ADDED**

---

## 🎯 Expected Result

### Before Fix:
```
❌ Error loading documents: [cloud_firestore/permission-denied]
❌ Red error banner at bottom
❌ Empty text fields
```

### After Fix:
```
✅ Screen loads successfully
✅ Two tabs: "Terms of Service" | "Privacy Policy"
✅ Text fields are editable
✅ "Save Changes" button works
✅ No permission errors
```

---

## 📱 Related Screens Fixed

This fix also resolves potential permission errors in:

1. ✅ **Security & Access Control** (uses `roles` collection)
2. ✅ **User Access Control** (uses `adminUsers` and `storeUsers` collections)
3. ✅ **Terms & Privacy Policy** (uses `legalDocuments` collection)

---

## 🚀 Quick Summary

**What to do:**

1. Open Firebase Console
2. Go to Firestore Database → Rules
3. Add 3 new collection rules at the end:
   - `legalDocuments`
   - `roles`
   - `storeUsers`
4. Click "Publish"
5. Restart your app
6. Test Terms & Privacy screen

**Time required:** 2-3 minutes

---

## ✅ Status

**Issue:** Permission denied for `legalDocuments` collection  
**Fix:** Updated Firestore rules  
**Local File:** ✅ Already updated in `firestore.rules`  
**Firebase Console:** ⚠️ **You need to publish manually** (see Method 1 above)  

---

**Last Updated:** February 14, 2026  
**Priority:** High - Blocks admin functionality
