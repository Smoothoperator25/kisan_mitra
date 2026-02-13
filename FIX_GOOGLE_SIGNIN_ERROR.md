# 🔴 URGENT FIX: Google Sign-In Error

## ❌ Problem Identified

The error "Google sign-in failed. Please try again." occurs because:

**The `google-services.json` file is missing the Android OAuth client configuration.**

Currently, it only has:
- Web client (client_type: 3)

**Missing:**
- Android client (client_type: 1) - REQUIRED for Google Sign-In on Android

---

## ✅ SOLUTION: Configure Firebase Properly

### Step 1: Get SHA-1 Fingerprint

#### Option A: Using Gradle (Recommended)
```bash
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android
gradlew signingReport
```

Look for the SHA-1 fingerprint under "Variant: debug" → "Config: debug"

#### Option B: Using Keytool
```bash
keytool -list -v -keystore C:\Users\lenovo\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copy the SHA1 fingerprint** (looks like: `A1:B2:C3:D4...`)

---

### Step 2: Add SHA-1 to Firebase Console

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com
   - Select project: **kisan-mitra-8cc98**

2. **Navigate to Project Settings:**
   - Click the gear icon (⚙️) next to "Project Overview"
   - Click "Project Settings"

3. **Select Your App:**
   - Scroll down to "Your apps"
   - Click on your Android app (`com.example.kisan_mitra`)

4. **Add SHA-1 Fingerprint:**
   - Scroll down to "SHA certificate fingerprints"
   - Click "Add fingerprint"
   - Paste your SHA-1 fingerprint
   - Click "Save"

5. **Download New Configuration:**
   - Click "Download google-services.json"
   - **IMPORTANT:** This new file will include the Android OAuth client!

---

### Step 3: Replace google-services.json

1. **Backup old file** (optional):
   ```bash
   copy android\app\google-services.json android\app\google-services.json.backup
   ```

2. **Replace with new file:**
   - Delete: `android\app\google-services.json`
   - Copy the newly downloaded `google-services.json` to `android\app\`

3. **Verify the new file has Android client:**
   Open the file and check for:
   ```json
   "oauth_client": [
     {
       "client_id": "XXX-XXX.apps.googleusercontent.com",
       "client_type": 1  // ← Should have client_type: 1 (Android)
     },
     {
       "client_id": "XXX-XXX.apps.googleusercontent.com",
       "client_type": 3  // ← Web client (already exists)
     }
   ]
   ```

---

### Step 4: Enable Google Sign-In in Firebase

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com
   - Select project: **kisan-mitra-8cc98**

2. **Navigate to Authentication:**
   - Click "Authentication" in the left menu
   - Click "Sign-in method" tab

3. **Enable Google Sign-In:**
   - Find "Google" in the providers list
   - Click on "Google"
   - Toggle "Enable" to ON
   - Add support email (your email)
   - Click "Save"

---

### Step 5: Clean and Rebuild

```bash
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

---

## 🧪 Test After Fix

1. **Run the app**
2. **Go to Farmer Login**
3. **Click "Sign in with Google"**
4. **Should show Google account picker** ✅
5. **Select account**
6. **Should sign in successfully** ✅

---

## 🔍 What the New google-services.json Should Look Like

```json
{
  "project_info": {
    "project_number": "255572322943",
    "project_id": "kisan-mitra-8cc98",
    "storage_bucket": "kisan-mitra-8cc98.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:255572322943:android:a8690862834a516d08ad4a",
        "android_client_info": {
          "package_name": "com.example.kisan_mitra"
        }
      },
      "oauth_client": [
        {
          "client_id": "255572322943-XXXXXXXXXX.apps.googleusercontent.com",
          "client_type": 1  // ← ANDROID CLIENT (NEW!)
        },
        {
          "client_id": "255572322943-arbnkcrrpimt9qfk1fcf08c2fvqkunr7.apps.googleusercontent.com",
          "client_type": 3  // ← Web client (existing)
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyCZovD7dO7yhC9m5LRRqxk2QyVB3ipPjgI"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "255572322943-XXXXXXXXXX.apps.googleusercontent.com",
              "client_type": 1
            },
            {
              "client_id": "255572322943-arbnkcrrpimt9qfk1fcf08c2fvqkunr7.apps.googleusercontent.com",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

**Key difference:** Now includes Android OAuth client with `"client_type": 1`

---

## 📋 Quick Checklist

- [ ] Get SHA-1 fingerprint
- [ ] Add SHA-1 to Firebase Console
- [ ] Download new google-services.json
- [ ] Replace old google-services.json
- [ ] Verify Android client exists (client_type: 1)
- [ ] Enable Google Sign-In in Firebase Auth
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run`
- [ ] Test Google Sign-In

---

## 🐛 Troubleshooting

### Still Getting Error After Fix?

#### Check 1: Verify SHA-1 Added
- Firebase Console → Project Settings → Your App
- Should see SHA-1 fingerprint listed

#### Check 2: Verify New google-services.json
- Open `android/app/google-services.json`
- Search for `"client_type": 1`
- If not found → Download again from Firebase

#### Check 3: Check Debug Logs
Run app and look at logs:
```bash
flutter run
```

Look for:
```
🔵 Starting Google Sign-In...
✅ Google account selected: user@gmail.com
🔑 Got auth tokens - AccessToken: true, IdToken: true
🔐 Created Firebase credential, signing in...
✅ Firebase sign-in successful: user@gmail.com
```

If you see:
```
❌ FirebaseAuthException: XXXX
❌ Google Sign-In Error: XXXX
```
→ Check the error code and fix accordingly

#### Check 4: Verify Package Name
- Firebase Console → Your App
- Package name: `com.example.kisan_mitra`
- Must match `android/app/build.gradle.kts`: `applicationId = "com.example.kisan_mitra"`

---

## 🎯 Why This Happened

**Problem:**
When you first created the Firebase project, you only added a Web app or didn't configure SHA-1 for the Android app.

**Result:**
- Firebase only generated Web OAuth client (client_type: 3)
- Google Sign-In SDK requires Android OAuth client (client_type: 1)
- Without Android client → Sign-in fails

**Fix:**
Adding SHA-1 fingerprint tells Firebase to generate the Android OAuth client configuration.

---

## ⏱️ Time to Fix

- **Get SHA-1:** 2 minutes
- **Configure Firebase:** 3 minutes
- **Replace file & rebuild:** 2 minutes
- **Total:** ~7 minutes

---

## 📞 Still Need Help?

If Google Sign-In still fails after following all steps:

1. **Share debug logs:**
   - Run `flutter run`
   - Click "Sign in with Google"
   - Copy the error logs (lines starting with 🔵 ✅ ❌)

2. **Verify Firebase setup:**
   - Screenshot of Firebase Console → Project Settings → Your App
   - Confirm SHA-1 is listed
   - Confirm Android client exists in google-services.json

3. **Check Firebase Authentication:**
   - Firebase Console → Authentication → Sign-in method
   - Confirm Google is "Enabled"

---

**Status:** 🔴 REQUIRES MANUAL FIREBASE CONFIGURATION  
**Estimated Time:** 7 minutes  
**Priority:** HIGH - Blocks Google Sign-In feature

Last Updated: February 13, 2026
