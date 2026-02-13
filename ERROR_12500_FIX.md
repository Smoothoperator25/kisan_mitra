# 🔴 ERROR 12500 - Developer Error FIX

## Error Message:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 12500: , null, null)
```

## What Error 12500 Means:
**"Developer Error"** - The Google Sign-In configuration in Firebase is incomplete or incorrect.

## Root Cause:
You **MUST** add the SHA-1 fingerprint to Firebase Console. Without it, Google Sign-In cannot work.

---

## ⚡ URGENT FIX - Follow These Steps NOW

### ✅ Step 1: Add SHA-1 to Firebase Console

Your SHA-1 fingerprint:
```
0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53
```

**Instructions:**

1. **Open Firebase Console:**
   - URL: https://console.firebase.google.com
   - Login with your Google account
   - Select project: **kisan-mitra-8cc98**

2. **Go to Project Settings:**
   - Click the **⚙️ gear icon** next to "Project Overview" (top left)
   - Click **"Project Settings"**

3. **Find Your Android App:**
   - Scroll down to **"Your apps"** section
   - Look for: **Android** app with package: `com.example.kisan_mitra`
   - Click on it to expand

4. **Add SHA-1 Fingerprint:**
   - Scroll down to **"SHA certificate fingerprints"**
   - Click **"Add fingerprint"** button
   - **Paste this:**
     ```
     0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53
     ```
   - Click **"Save"** or **"Add"**

5. **Download New google-services.json:**
   - **IMPORTANT:** After adding SHA-1, you MUST download a new file
   - Click **"Download google-services.json"** button
   - Save the file to your Downloads folder

---

### ✅ Step 2: Replace google-services.json

1. **Navigate to:**
   ```
   C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\
   ```

2. **Backup old file:**
   - Find `google-services.json`
   - Rename it to `google-services.json.old`

3. **Add new file:**
   - Copy the NEW `google-services.json` from Downloads
   - Paste it into: `android\app\`

4. **Verify the new file:**
   - Open `google-services.json`
   - Look for `"client_type": 1` (Android client)
   - If you see it → ✅ Correct!
   - If you only see `"client_type": 3` → ❌ Download again

---

### ✅ Step 3: Enable Google Sign-In

1. **In Firebase Console:**
   - Click **"Authentication"** in left sidebar
   - Click **"Sign-in method"** tab
   - Find **"Google"** in the providers list

2. **Enable it:**
   - Click on **"Google"**
   - Toggle **"Enable"** to ON
   - **Project support email:** Enter your email
   - Click **"Save"**

---

### ✅ Step 4: Clean and Rebuild

Open PowerShell or Command Prompt:

```powershell
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Rebuild and run
flutter run
```

**Wait for app to rebuild** (may take 1-2 minutes)

---

### ✅ Step 5: Test Again

1. App opens
2. Go to **Farmer Login**
3. Click **"Sign in with Google"**
4. **Should work now!** ✅

---

## 🎯 Why This Specific Error?

### Error 12500 happens when:
1. ❌ SHA-1 fingerprint not added to Firebase
2. ❌ Package name mismatch
3. ❌ google-services.json not updated after adding SHA-1
4. ❌ Google Sign-In not enabled in Firebase Auth

### After you add SHA-1:
- ✅ Firebase generates Android OAuth client
- ✅ google-services.json gets updated
- ✅ Google Sign-In works!

---

## 📊 Verification

### Before Adding SHA-1:
```json
// google-services.json
"oauth_client": [
  {
    "client_id": "XXX.apps.googleusercontent.com",
    "client_type": 3  // ← Only Web client
  }
]
```
❌ **Result:** Error 12500

### After Adding SHA-1:
```json
// google-services.json (NEW)
"oauth_client": [
  {
    "client_id": "XXXXXXXXXX.apps.googleusercontent.com",
    "client_type": 1  // ← Android client (ADDED!)
  },
  {
    "client_id": "XXX.apps.googleusercontent.com",
    "client_type": 3  // ← Web client
  }
]
```
✅ **Result:** Google Sign-In works!

---

## 🔍 Quick Checklist

Before testing again:

- [ ] SHA-1 added to Firebase Console: `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`
- [ ] NEW google-services.json downloaded from Firebase
- [ ] Old google-services.json backed up
- [ ] New google-services.json placed in `android/app/`
- [ ] Verified new file has `"client_type": 1`
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] Support email added
- [ ] `flutter clean` completed
- [ ] `flutter pub get` completed
- [ ] App rebuilt successfully
- [ ] Ready to test!

---

## 📸 Visual Guide

### Firebase Console → Project Settings:
```
┌─────────────────────────────────────┐
│  Project Settings                   │
├─────────────────────────────────────┤
│                                     │
│  Your apps                          │
│                                     │
│  📱 Android                         │
│     Package: com.example.kisan_m... │
│                                     │
│     SHA certificate fingerprints    │
│     ┌───────────────────────────┐  │
│     │ [Add fingerprint]         │  │ ← Click here
│     └───────────────────────────┘  │
│                                     │
│     [Download google-services.json] │ ← Then click here
└─────────────────────────────────────┘
```

### Firebase Console → Authentication:
```
┌─────────────────────────────────────┐
│  Authentication                     │
├─────────────────────────────────────┤
│                                     │
│  Sign-in method                     │
│                                     │
│  Providers:                         │
│  ┌───────────────────────────────┐ │
│  │ Google         [Enabled ✓]   │ │ ← Make sure ON
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## ⏱️ Time Required

- Add SHA-1 to Firebase: **2 minutes**
- Download new google-services.json: **30 seconds**
- Replace file: **30 seconds**
- Enable Google Sign-In: **1 minute**
- Rebuild app: **2 minutes**
- **Total: ~6 minutes**

---

## 🐛 Still Getting Error 12500?

### Check 1: Verify SHA-1 is Added
- Go to Firebase Console → Project Settings
- Scroll to "SHA certificate fingerprints"
- You should see: `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`
- If not there → Add it again

### Check 2: Verify New File Downloaded
- Open `android/app/google-services.json`
- Search for `"client_type": 1`
- If found → ✅ Correct file
- If NOT found → Download again from Firebase

### Check 3: Package Name Match
- Firebase Console shows: `com.example.kisan_mitra`
- android/app/build.gradle.kts shows: `applicationId = "com.example.kisan_mitra"`
- Must match exactly ✅

### Check 4: Clean Build
```powershell
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Delete build folders
Remove-Item -Recurse -Force build
Remove-Item -Recurse -Force android\build
Remove-Item -Recurse -Force android\app\build

# Rebuild
flutter clean
flutter pub get
flutter run
```

---

## 🎯 Expected Behavior After Fix

### Before:
```
Click "Sign in with Google"
  ↓
❌ Error 12500: Developer Error
  ↓
Red error message shown
```

### After:
```
Click "Sign in with Google"
  ↓
✅ Google account picker appears
  ↓
Select Google account
  ↓
✅ Sign in successful!
  ↓
Navigate to Farmer Dashboard
```

---

## 📞 Need More Help?

If error persists after following ALL steps:

1. **Screenshot Firebase Console:**
   - Project Settings → Your app
   - Show SHA fingerprints section
   - Show google-services.json download button

2. **Screenshot google-services.json:**
   - Open the file
   - Show the `oauth_client` section
   - Verify `client_type: 1` exists

3. **Run with logs:**
   ```bash
   flutter run -v
   ```
   - Copy the error logs
   - Look for "sign_in_failed" messages

---

**⚠️ CRITICAL:** You CANNOT skip adding SHA-1 to Firebase. This is a **REQUIRED** step for Google Sign-In to work on Android.

**Status:** 🔴 REQUIRES IMMEDIATE ACTION  
**Action:** Add SHA-1 to Firebase Console NOW  
**Your SHA-1:** `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`  
**Time:** 6 minutes  
**Difficulty:** Easy - Just follow steps

---

Last Updated: February 13, 2026
