# ⚡ MAPBOX QUICK SETUP - 3 SIMPLE STEPS

## 🎯 Your App Now Uses MAPBOX ONLY

All Google Maps code has been removed. You only need **ONE** Mapbox token!

---

## ✅ STEP 1: Get Mapbox Token (2 minutes)

### Go to Mapbox:
```
https://account.mapbox.com/
```

### What to do:
1. **Sign up** (if new) or **Login**
2. After login, click: **"Access tokens"** (left sidebar)
3. **Copy** the "Default public token"
4. Token looks like: `pk.eyJ1IjoieW91cm5hbWUi...`

**Save this token!** You'll need it for the next step.

---

## ✅ STEP 2: Update 2 Files (1 minute)

### File 1: `android/app/src/main/res/values/strings.xml`

✅ **Already created for you!**

**What to change:**
```xml
<!-- BEFORE -->
<string name="mapbox_access_token">YOUR_MAPBOX_TOKEN_HERE</string>

<!-- AFTER -->
<string name="mapbox_access_token">pk.eyJ1IjoieW91cm5hbWUi...</string>
```

**Full path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\android\app\src\main\res\values\strings.xml
```

---

### File 2: `lib/features/farmer/fertilizer_search/mapbox_service.dart`

**Line 8** - Change:
```dart
// BEFORE
static const String _accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';

// AFTER
static const String _accessToken = 'pk.eyJ1IjoieW91cm5hbWUi...';
```

**Full path:**
```
C:\Users\lenovo\AndroidStudioProjects\kisan_mitra\lib\features\farmer\fertilizer_search\mapbox_service.dart
```

---

## ✅ STEP 3: Rebuild App (2 minutes)

Open terminal and run:

```powershell
flutter clean
flutter pub get
flutter run
```

**Done! Maps are now working!** 🎉

---

## 🧪 TEST YOUR MAPS

### ✅ Test 1: Store Location
1. Login as **Store**
2. Go to **Location Settings**
3. Map loads → **Tap** to set location → **Save**

### ✅ Test 2: Fertilizer Search
1. Login as **Farmer**
2. Go to **Fertilizer Search**
3. Map loads → Shows stores → Tap store → Shows route

### ✅ Test 3: Store Registration
1. Create new Store account
2. During Step 2, tap on map to select location
3. Works without API key! (FREE OpenStreetMap)

---

## 📋 QUICK CHECKLIST

- [ ] Got Mapbox token from: https://account.mapbox.com/
- [ ] Updated `strings.xml` (Line 10)
- [ ] Updated `mapbox_service.dart` (Line 8)
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter run`
- [ ] Tested Store Location screen
- [ ] Tested Fertilizer Search screen
- [ ] Tested Store Registration

---

## 🗺️ WHAT CHANGED

### ❌ Removed (Google Maps):
- google_maps_flutter package
- Google Maps API Key
- Google Cloud Console setup
- flutter_polyline_points

### ✅ Now Using (Mapbox):
- mapbox_maps_flutter (all interactive maps)
- flutter_map (simple OpenStreetMap - FREE)
- Single Mapbox token

---

## 💰 COST

**Mapbox Free Tier:**
- 50,000 map loads/month = FREE
- 100,000 requests/month = FREE

**Your Usage:**
- ~60-250 loads/day
- ~1,800-7,500/month

**Total Cost: $0** ✅

---

## 🔧 FILES LOCATIONS

### Where to find files:

**File 1: strings.xml**
```
android/
  └── app/
      └── src/
          └── main/
              └── res/
                  └── values/
                      └── strings.xml  ← Update Line 10
```

**File 2: mapbox_service.dart**
```
lib/
  └── features/
      └── farmer/
          └── fertilizer_search/
              └── mapbox_service.dart  ← Update Line 8
```

---

## 🐛 TROUBLESHOOTING

### Map is blank/grey?
- Check token in both files
- Verify token starts with `pk.`
- Run `flutter clean` again

### "Invalid token" error?
- Go to: https://account.mapbox.com/access-tokens/
- Copy token again (check no extra spaces)
- Update both files
- Rebuild app

### App crashes?
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 📱 SCREENS USING MAPS

| Screen | Map Type | API Key Needed? |
|--------|----------|----------------|
| Store Location | Mapbox | Yes (Mapbox token) |
| Fertilizer Search | Mapbox | Yes (Mapbox token) |
| Store Registration | Flutter Map | No (FREE!) |

---

## 🎯 PASTE YOUR TOKEN HERE

**For reference, save your Mapbox token:**

```
Mapbox Access Token:
┌────────────────────────────────────────────────────┐
│                                                    │
│  pk.eyJ1IjoiX________YOUR_TOKEN_________          │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Where to use it:**
- File 1: `strings.xml` (Line 10)
- File 2: `mapbox_service.dart` (Line 8)

---

## 🚀 YOU'RE DONE!

**Total steps:** 3  
**Total time:** 5 minutes  
**Total cost:** $0 (FREE!)  

**Maps working:** ✅

---

**For detailed guide, see:** `MAPBOX_ONLY_SETUP.md`

**Created:** February 13, 2026  
**Kisan Mitra v1.0.0**

