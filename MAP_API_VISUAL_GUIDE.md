# 🗺️ MAP API KEY LOCATIONS - VISUAL GUIDE

## 📊 Overview

Your app uses **2 map services**, each needs keys in **2 locations**:

```
GOOGLE MAPS API KEY
├── Location 1: AndroidManifest.xml
└── Location 2: app_constants.dart

MAPBOX ACCESS TOKEN
├── Location 1: strings.xml
└── Location 2: mapbox_service.dart
```

---

## 🔑 GOOGLE MAPS API KEY

### WHERE TO GET IT:
1. Go to: https://console.cloud.google.com/
2. Project: kisan-mitra-8cc98
3. Enable: Maps SDK for Android, Directions API, Geocoding API
4. Credentials → Create API Key
5. Restrict to Android app (package: `com.example.kisan_mitra`)

### KEY FORMAT:
```
AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW
```

---

## 📍 LOCATION 1: AndroidManifest.xml

**Full Path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\src\main\AndroidManifest.xml
```

**Line Number:** 40-42

**What to Change:**
```xml
<!-- BEFORE (Line 40-42) -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

```xml
<!-- AFTER (Line 40-42) -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW"/>
    <!-- ↑ Paste your Google Maps API key here -->
```

**How to Edit:**
1. Open: `android/app/src/main/AndroidManifest.xml`
2. Find line 42: `android:value="YOUR_API_KEY_HERE"/>`
3. Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key
4. Keep the quotes and closing `"/>`
5. Save file

---

## 📍 LOCATION 2: app_constants.dart

**Full Path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\lib\core\constants\app_constants.dart
```

**Line Number:** 32-33

**What to Change:**
```dart
// BEFORE (Line 32-33)
static const String googleMapsApiKey =
    'YOUR_API_KEY_HERE'; // Placeholder - Replace with actual key
```

```dart
// AFTER (Line 32-33)
static const String googleMapsApiKey =
    'AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW'; // Your Google Maps API key
    // ↑ Paste your Google Maps API key here
```

**How to Edit:**
1. Open: `lib/core/constants/app_constants.dart`
2. Find line 33: `'YOUR_API_KEY_HERE'`
3. Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key
4. Keep the single quotes
5. Save file

---

## 🔑 MAPBOX ACCESS TOKEN

### WHERE TO GET IT:
1. Go to: https://account.mapbox.com/
2. Sign up or login
3. Access Tokens page
4. Copy default public token (or create new one)

### TOKEN FORMAT:
```
pk.eyJ1IjoieW91cm5hbWUiLCJhIjoiY2xxeHl6MTIzMDAuLi4
```
(Always starts with `pk.`)

---

## 📍 LOCATION 3: strings.xml

**Full Path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\src\main\res\values\strings.xml
```

**Status:** ✅ File already created for you!

**What to Change:**
```xml
<!-- BEFORE -->
<string name="mapbox_access_token">YOUR_MAPBOX_TOKEN_HERE</string>
```

```xml
<!-- AFTER -->
<string name="mapbox_access_token">pk.eyJ1IjoieW91cm5hbWUiLCJhIjoiY2xxeHl6MTIzMDAuLi4</string>
<!-- ↑ Paste your Mapbox token here -->
```

**How to Edit:**
1. Open: `android/app/src/main/res/values/strings.xml`
2. Find: `YOUR_MAPBOX_TOKEN_HERE`
3. Replace with your actual Mapbox access token
4. Keep the closing `</string>` tag
5. Save file

---

## 📍 LOCATION 4: mapbox_service.dart

**Full Path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\lib\features\farmer\fertilizer_search\mapbox_service.dart
```

**Line Number:** 8

**What to Change:**
```dart
// BEFORE (Line 8)
static const String _accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';
```

```dart
// AFTER (Line 8)
static const String _accessToken = 'pk.eyJ1IjoieW91cm5hbWUiLCJhIjoiY2xxeHl6MTIzMDAuLi4';
// ↑ Paste your Mapbox token here
```

**How to Edit:**
1. Open: `lib/features/farmer/fertilizer_search/mapbox_service.dart`
2. Find line 8: `'YOUR_MAPBOX_ACCESS_TOKEN'`
3. Replace `YOUR_MAPBOX_ACCESS_TOKEN` with your actual Mapbox token
4. Keep the single quotes
5. Save file

---

## 🎯 CHECKLIST

After getting your API keys, update these 4 files:

### Google Maps API Key:
- [ ] **File 1:** `android/app/src/main/AndroidManifest.xml` (Line 42)
- [ ] **File 2:** `lib/core/constants/app_constants.dart` (Line 33)

### Mapbox Access Token:
- [ ] **File 3:** `android/app/src/main/res/values/strings.xml` (Already created)
- [ ] **File 4:** `lib/features/farmer/fertilizer_search/mapbox_service.dart` (Line 8)

### After Updates:
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run`
- [ ] Test: Store location screen (Google Maps)
- [ ] Test: Fertilizer search screen (Mapbox)

---

## 🔍 FINDING THE FILES

### In Android Studio / VS Code:

**Method 1: Project Explorer**
```
kisan_mitra/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               ├── AndroidManifest.xml ← File 1
│               └── res/
│                   └── values/
│                       └── strings.xml ← File 3
└── lib/
    ├── core/
    │   └── constants/
    │       └── app_constants.dart ← File 2
    └── features/
        └── farmer/
            └── fertilizer_search/
                └── mapbox_service.dart ← File 4
```

**Method 2: Quick Open (Ctrl+P or Cmd+P)**
- Type: `AndroidManifest.xml`
- Type: `app_constants.dart`
- Type: `strings.xml`
- Type: `mapbox_service.dart`

**Method 3: Search (Ctrl+Shift+F or Cmd+Shift+F)**
- Search for: `YOUR_API_KEY_HERE`
- Search for: `YOUR_MAPBOX_ACCESS_TOKEN`

---

## 💡 TIPS

### Copy-Paste Safely:
1. **Don't copy quotes** - they're already in the file
2. **Don't copy comments** - only copy the key/token
3. **Check for spaces** - no extra spaces at start or end
4. **Verify format** - Google key starts with `AIza`, Mapbox starts with `pk.`

### Common Mistakes:
- ❌ Copying `YOUR_API_KEY_HERE` literally
- ❌ Adding extra quotes
- ❌ Missing characters when copying
- ❌ Not saving the file after editing
- ❌ Forgetting to rebuild app

### Correct Examples:
```dart
// ✅ CORRECT
'AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW'

// ❌ WRONG (extra quotes)
''AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW''

// ❌ WRONG (still placeholder)
'YOUR_API_KEY_HERE'

// ❌ WRONG (missing quotes)
AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW
```

---

## 🎬 QUICK START

**Total Time: 15 minutes**

1. **Get Google API Key** (5 min)
   - https://console.cloud.google.com/
   
2. **Get Mapbox Token** (2 min)
   - https://account.mapbox.com/

3. **Update Files** (5 min)
   - AndroidManifest.xml
   - app_constants.dart
   - strings.xml (already created)
   - mapbox_service.dart

4. **Rebuild** (3 min)
   ```
   flutter clean
   flutter pub get
   flutter run
   ```

**Maps will work!** ✅

---

## 📞 STILL STUCK?

### Can't find the files?
- Use Project Explorer sidebar
- Or press: Ctrl+Shift+N (Windows) / Cmd+Shift+O (Mac)
- Type filename to jump directly

### Can't get API key?
- Make sure you're logged into Google Cloud Console
- Select correct project: kisan-mitra-8cc98
- Check billing is enabled (free tier is fine)

### Maps still not showing?
- Check Android Logcat for errors
- Verify keys have no typos
- Make sure you saved all files
- Try `flutter clean` again

---

**You can do this! Follow the steps one by one.** 🚀

