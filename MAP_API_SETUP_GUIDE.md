# 🗺️ MAP API SETUP - COMPLETE GUIDE

## 📍 Overview

Your Kisan Mitra app uses **TWO** different map services:
1. **Google Maps** - For Store Location Screen
2. **Mapbox Maps** - For Fertilizer Search Screen (Farmer)

Both need API keys to work. Currently both are showing placeholder values.

---

## 🚨 CURRENT ISSUE

**Maps are not showing because:**
- Google Maps API Key = `YOUR_API_KEY_HERE` (Placeholder)
- Mapbox Access Token = `YOUR_MAPBOX_ACCESS_TOKEN` (Placeholder)

---

## 📋 PART 1: GOOGLE MAPS API SETUP

### Step 1: Create Google Maps API Key

1. **Go to Google Cloud Console:**
   - URL: https://console.cloud.google.com/
   - Select your Firebase project: `kisan-mitra-8cc98`

2. **Enable Google Maps SDK:**
   - In search bar, type: "Maps SDK for Android"
   - Click: **Enable API**
   - Also enable: "Directions API" (for route finding)
   - Also enable: "Geocoding API" (for address lookup)

3. **Create API Key:**
   - Go to: APIs & Services → Credentials
   - Click: **+ CREATE CREDENTIALS**
   - Select: **API Key**
   - Copy the API key (looks like: `AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW`)

4. **Restrict API Key (IMPORTANT for Security):**
   - Click on the newly created key
   - Under "Application restrictions":
     - Select: **Android apps**
     - Click: **+ Add an item**
     - Package name: `com.example.kisan_mitra`
     - SHA-1: `0D:DC:8B:EC:AF:D6:07:5A:53:B4:61:AA:A4:DC:9E:86:4A:83:12:53`
   - Under "API restrictions":
     - Select: **Restrict key**
     - Check these APIs:
       - ✅ Maps SDK for Android
       - ✅ Directions API
       - ✅ Geocoding API
   - Click: **SAVE**

### Step 2: Add API Key to Android App

**File:** `android/app/src/main/AndroidManifest.xml`

**Find this line (around line 42):**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**Replace with your actual key:**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW"/>
```

### Step 3: Add API Key to App Constants

**File:** `lib/core/constants/app_constants.dart`

**Find this line (around line 32):**
```dart
static const String googleMapsApiKey =
    'YOUR_API_KEY_HERE'; // Placeholder - Replace with actual key
```

**Replace with:**
```dart
static const String googleMapsApiKey =
    'AIzaSyAbCdEf1234567890GhIjKlMnOpQrStUvW'; // Your actual Google Maps API key
```

---

## 📋 PART 2: MAPBOX API SETUP

### Step 1: Create Mapbox Account & Token

1. **Sign Up/Login to Mapbox:**
   - URL: https://account.mapbox.com/
   - Create free account (if you don't have one)

2. **Get Access Token:**
   - Go to: https://account.mapbox.com/access-tokens/
   - You'll see a **Default public token** already created
   - Copy this token (looks like: `pk.eyJ1IjoieW91cnVzZXJuYW1lIiwiYSI6ImNscXh5ejEyMzA...`)
   - OR click **+ Create a token** for a new one

3. **Token Scopes (if creating new):**
   - ✅ styles:read
   - ✅ fonts:read
   - ✅ datasets:read
   - ✅ navigation:read
   - Public token (starts with `pk.`)

### Step 2: Add Mapbox Token to Android

**File:** `android/app/src/main/res/values/strings.xml`

Create this file if it doesn't exist:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="mapbox_access_token">YOUR_MAPBOX_ACCESS_TOKEN</string>
</resources>
```

Replace `YOUR_MAPBOX_ACCESS_TOKEN` with your actual token.

### Step 3: Add Token to Mapbox Service

**File:** `lib/features/farmer/fertilizer_search/mapbox_service.dart`

**Find this line (line 8):**
```dart
static const String _accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';
```

**Replace with:**
```dart
static const String _accessToken = 'pk.eyJ1IjoieW91cnVzZXJuYW1lIiwiYSI6ImNscXh5ejEyMzA...';
```

---

## 🔧 QUICK SETUP COMMANDS

After adding both API keys, run these commands:

```powershell
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild app
flutter run
```

---

## 📍 WHERE MAPS ARE USED

### 1. Google Maps (google_maps_flutter)
**Used in:**
- ✅ **Store Location Screen** (`lib/features/store/location/store_location_screen.dart`)
  - Allows stores to set their location with draggable marker
  - Shows Google Map with current location

**Features:**
- Interactive map with markers
- Draggable markers for location selection
- Reverse geocoding (coordinates → address)
- Directions API for routes

### 2. Mapbox Maps (mapbox_maps_flutter)
**Used in:**
- ✅ **Fertilizer Search Screen** (`lib/features/farmer/fertilizer_search/fertilizer_search_screen.dart`)
  - Shows nearby stores on map
  - Displays route to selected store
  - Shows user's current location

**Features:**
- Custom styled maps
- Route visualization
- Store markers with annotations
- Distance calculations

### 3. OpenStreetMap (flutter_map)
**Used in:**
- ✅ **Store Registration Screen** (`lib/features/store/auth/store_registration_screen.dart`)
  - Simple map for selecting location during registration
  - No API key needed (uses free OpenStreetMap tiles)

---

## ✅ VERIFICATION STEPS

### Test Google Maps:
1. Login as **Store Owner**
2. Go to: **Location Settings** or **Set Store Location**
3. You should see a map with a draggable marker
4. If map shows, Google Maps is working! ✅

### Test Mapbox Maps:
1. Login as **Farmer**
2. Go to: **Fertilizer Search** or **Find Nearby Stores**
3. You should see a styled map with store locations
4. If map shows, Mapbox is working! ✅

---

## 💰 PRICING INFO

### Google Maps
- **Free Tier:** $200 credit/month
- **Map loads:** First 100,000 per month = FREE
- **Directions API:** First 40,000 per month = FREE
- Your app usage should stay within free tier

### Mapbox
- **Free Tier:** 
  - 50,000 map loads/month = FREE
  - 100,000 requests/month = FREE
- Your app usage should stay within free tier

**Both services are FREE for development and small-scale apps!**

---

## 🔐 SECURITY BEST PRACTICES

### ✅ DO:
- Restrict API keys to your Android package name
- Add SHA-1 fingerprint restrictions
- Enable only required APIs
- Monitor usage in respective consoles

### ❌ DON'T:
- Share API keys publicly
- Commit keys to public repositories
- Leave keys unrestricted
- Use same key for different apps

---

## 🐛 TROUBLESHOOTING

### Map Shows Grey/Blank Screen
**Cause:** Invalid or missing API key
**Fix:** Double-check key in AndroidManifest.xml and app_constants.dart

### "Map Failed to Load" Error
**Cause:** API not enabled in Google Cloud Console
**Fix:** Enable Maps SDK for Android

### Mapbox Map Not Showing
**Cause:** Invalid Mapbox token
**Fix:** Verify token in mapbox_service.dart

### Directions Not Working
**Cause:** Directions API not enabled
**Fix:** Enable Directions API in Google Cloud Console

---

## 📱 FILES TO MODIFY

### For Google Maps:
1. ✅ `android/app/src/main/AndroidManifest.xml` (Line 42)
2. ✅ `lib/core/constants/app_constants.dart` (Line 32)

### For Mapbox:
1. ✅ `android/app/src/main/res/values/strings.xml` (Create if needed)
2. ✅ `lib/features/farmer/fertilizer_search/mapbox_service.dart` (Line 8)

---

## 🎯 SUMMARY

**To fix maps in your app:**

1. **Get Google Maps API Key** (5 minutes)
   - Go to: https://console.cloud.google.com/
   - Enable: Maps SDK for Android, Directions API, Geocoding API
   - Create & restrict API key

2. **Get Mapbox Access Token** (2 minutes)
   - Go to: https://account.mapbox.com/
   - Copy default public token

3. **Update 4 Files** (2 minutes)
   - AndroidManifest.xml
   - app_constants.dart
   - strings.xml (create)
   - mapbox_service.dart

4. **Rebuild App** (2 minutes)
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

**Total Time: ~11 minutes**

---

## 📞 NEED HELP?

If maps still don't work after following this guide:

1. Check Android Logcat for error messages
2. Verify API key is correct (no extra spaces)
3. Ensure APIs are enabled in Google Cloud Console
4. Check Mapbox token is valid and active
5. Make sure internet permission is in AndroidManifest.xml (already added)

---

## 🌟 NEXT STEPS AFTER SETUP

Once maps are working, you can:
- Customize map styles in Mapbox Studio
- Add more markers and annotations
- Implement clustering for many stores
- Add traffic layer to Google Maps
- Enable 3D buildings view
- Add custom map themes

---

**Your API keys will be added to these locations:**

**Google Maps API Key:**
```
android/app/src/main/AndroidManifest.xml → Line 42
lib/core/constants/app_constants.dart → Line 32
```

**Mapbox Access Token:**
```
android/app/src/main/res/values/strings.xml → Create file
lib/features/farmer/fertilizer_search/mapbox_service.dart → Line 8
```

---

**Created:** February 13, 2026  
**App:** Kisan Mitra  
**Version:** 1.0.0

