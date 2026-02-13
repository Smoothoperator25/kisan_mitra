# ✅ QUICK FIX: Google Sign-In Error - Step by Step

## 🎯 Your SHA-1 Fingerprint

```
SHA1: 0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53
```

**Copy this SHA-1 value above** ☝️

---

## 📋 Step-by-Step Instructions (5 Minutes)

### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com**
2. Click on project: **kisan-mitra-8cc98**

---

### Step 2: Navigate to Project Settings

1. Click the **⚙️ gear icon** next to "Project Overview" (top left)
2. Click **"Project Settings"**

---

### Step 3: Select Your Android App

1. Scroll down to **"Your apps"** section
2. Find your Android app: **`com.example.kisan_mitra`**
3. If you see it → Click on it
4. If you don't see it → You may need to add an Android app first

---

### Step 4: Add SHA-1 Fingerprint

1. Scroll down to **"SHA certificate fingerprints"** section
2. Click **"Add fingerprint"** button
3. Paste this SHA-1:
   ```
   0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53
   ```
4. Click **"Save"**

✅ SHA-1 added successfully!

---

### Step 5: Download New google-services.json

1. Still in Project Settings → Your Android app
2. Click **"Download google-services.json"** button
3. Save the file (it will download to your Downloads folder)

---

### Step 6: Replace Old google-services.json

1. **Open File Explorer**
2. **Navigate to:**
   ```
   C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\
   ```

3. **Delete or rename the old file:**
   - Right-click `google-services.json`
   - Rename to `google-services.json.old` (for backup)
   - Or delete it

4. **Copy the new file:**
   - Go to your Downloads folder
   - Find the new `google-services.json`
   - Copy it to: `C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\`

✅ File replaced!

---

### Step 7: Enable Google Sign-In in Firebase

1. In Firebase Console, click **"Authentication"** in left menu
2. Click **"Sign-in method"** tab
3. Find **"Google"** in the list
4. Click on **"Google"**
5. Toggle **"Enable"** to ON
6. Add your **support email** (e.g., your@email.com)
7. Click **"Save"**

✅ Google Sign-In enabled!

---

### Step 8: Clean and Rebuild App

Open PowerShell/Command Prompt and run:

```powershell
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run
```

✅ App rebuilt with new configuration!

---

### Step 9: Test Google Sign-In

1. **App should start**
2. **Go to Farmer Login**
3. **Click "Sign in with Google" button**
4. **Google account picker should appear** 🎉
5. **Select your Google account**
6. **Grant permissions**
7. **Should sign in successfully!** ✅

---

## 🎉 What Changed?

### Before:
- google-services.json only had Web client
- No Android OAuth client
- Google Sign-In failed

### After:
- google-services.json now has Android OAuth client
- Firebase knows your app's signature (SHA-1)
- Google Sign-In works! 🎉

---

## 🔍 Verify the Fix

### Check the new google-services.json:

Open `android\app\google-services.json` and look for:

```json
"oauth_client": [
  {
    "client_id": "XXXXXXXXXX.apps.googleusercontent.com",
    "client_type": 1  // ← Android client (NEW!)
  },
  {
    "client_id": "255572322943-arbnkcrrpimt9qfk1fcf08c2fvqkunr7.apps.googleusercontent.com",
    "client_type": 3  // ← Web client (existing)
  }
]
```

✅ If you see `"client_type": 1` → Configuration is correct!

---

## 📱 Expected Flow After Fix

1. Click "Sign in with Google"
2. **Google account picker appears**
3. Select account
4. Grant permissions (if first time)
5. **App creates profile automatically**
6. **Navigate to Farmer Dashboard**
7. **Success!** 🎉

---

## 🐛 Still Having Issues?

### Issue 1: "Account picker doesn't appear"
**Fix:** Make sure you ran `flutter clean` and `flutter run`

### Issue 2: "Sign in still fails"
**Fix:** 
1. Check Firebase Console → Authentication → Sign-in method
2. Make sure "Google" is **Enabled**
3. Check that SHA-1 is listed in Project Settings

### Issue 3: "Invalid client" error
**Fix:**
1. Download google-services.json again from Firebase
2. Make sure it's in: `android/app/google-services.json`
3. Run `flutter clean` again

---

## ⏱️ Time Breakdown

- Step 1-2: Open Firebase (30 seconds)
- Step 3-4: Add SHA-1 (1 minute)
- Step 5-6: Replace file (1 minute)
- Step 7: Enable Google Sign-In (1 minute)
- Step 8: Rebuild app (2 minutes)
- **Total: ~5 minutes**

---

## ✅ Quick Checklist

- [ ] SHA-1 copied: `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`
- [ ] Opened Firebase Console
- [ ] Found Android app in Project Settings
- [ ] Added SHA-1 fingerprint
- [ ] Downloaded new google-services.json
- [ ] Replaced old google-services.json in android/app/
- [ ] Enabled Google Sign-In in Firebase Authentication
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter run`
- [ ] Tested Google Sign-In
- [ ] ✅ **WORKING!**

---

## 📞 Need Visual Guide?

If you need screenshots for any step:
1. Open Firebase Console
2. Each section has help (?) icons
3. Firebase documentation: https://firebase.google.com/docs

---

**Status:** ✅ SHA-1 Retrieved - Ready to Configure  
**Your SHA-1:** `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`  
**Time Needed:** 5 minutes  
**Difficulty:** Easy

Last Updated: February 13, 2026
