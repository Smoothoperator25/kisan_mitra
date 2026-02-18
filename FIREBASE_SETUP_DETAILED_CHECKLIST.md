# ✅ SETUP CHECKLIST - BUILD FIREBASE DATA

## 🎯 GOAL
Create 3 Firebase collections so fertilizer search shows different prices from different shops.

---

## 📋 PHASE 1: PREPARE (Before Starting)

```
☐ Open Firebase Console: https://console.firebase.google.com
☐ Select Kisan Mitra project
☐ Click: Firestore Database
☐ Get ready to create collections
```

---

## 📋 PHASE 2: CREATE fertilizer_master (3 min)

### Create Collection
```
☐ Click: "+ Create collection"
☐ Name: fertilizer_master
☐ Click: "Next"
☐ Click: "Auto ID"
```

### Add Urea Document
```
☐ Add field: name (String) = Urea
☐ Add field: category (String) = Nitrogenous
☐ Add field: npkComposition (String) = 46:0:0
☐ Add field: description (String) = Nitrogen rich fertilizer
☐ Add field: image_url (String) = https://example.com/urea.jpg
☐ Add field: is_active (Boolean) = true
☐ Click: Save
☐ WRITE DOWN: Urea Document ID = _____________________________
```

### Add DAP Document (Optional)
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: name (String) = DAP
☐ Add field: category (String) = Phosphate
☐ Add field: npkComposition (String) = 18:46:0
☐ Add field: description (String) = Diammonium Phosphate
☐ Add field: image_url (String) = https://example.com/dap.jpg
☐ Add field: is_active (Boolean) = true
☐ Click: Save
☐ WRITE DOWN: DAP Document ID = _____________________________
```

---

## 📋 PHASE 3: CREATE stores (3 min)

### Check if Collection Exists
```
☐ Look in left menu for "stores" collection
☐ If NOT exists: Continue to create
☐ If EXISTS: Skip to "Add Documents"
```

### Create Collection (if doesn't exist)
```
☐ Click: "+ Create collection"
☐ Name: stores
☐ Click: "Next"
☐ Click: "Auto ID"
```

### Add Shop A Document
```
☐ Add field: storeName (String) = ABC Fertilizer & Seeds
☐ Add field: ownerName (String) = Rajesh Kumar
☐ Add field: phone (String) = 9876543210
☐ Add field: city (String) = Delhi
☐ Add field: state (String) = Delhi
☐ Add field: latitude (Number) = 28.6139
☐ Add field: longitude (Number) = 77.2090
☐ Add field: isVerified (Boolean) = true
☐ Add field: rating (Number) = 4.8
☐ Add field: total_reviews (Number) = 150
☐ Click: Save
☐ WRITE DOWN: Shop A Document ID = _____________________________
```

### Add Shop B Document
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeName (String) = XYZ Agri Supplies
☐ Add field: ownerName (String) = Priya Singh
☐ Add field: phone (String) = 9876543211
☐ Add field: city (String) = Delhi
☐ Add field: state (String) = Delhi
☐ Add field: latitude (Number) = 28.6150
☐ Add field: longitude (Number) = 77.2100
☐ Add field: isVerified (Boolean) = true
☐ Add field: rating (Number) = 4.5
☐ Add field: total_reviews (Number) = 120
☐ Click: Save
☐ WRITE DOWN: Shop B Document ID = _____________________________
```

### Add Shop C Document
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeName (String) = Green Fertilizer House
☐ Add field: ownerName (String) = Amit Patel
☐ Add field: phone (String) = 9876543212
☐ Add field: city (String) = Delhi
☐ Add field: state (String) = Delhi
☐ Add field: latitude (Number) = 28.6160
☐ Add field: longitude (Number) = 77.2110
☐ Add field: isVerified (Boolean) = true
☐ Add field: rating (Number) = 4.2
☐ Add field: total_reviews (Number) = 85
☐ Click: Save
☐ WRITE DOWN: Shop C Document ID = _____________________________
```

---

## 📋 PHASE 4: CREATE store_fertilizers (5 min)

### Create Collection
```
☐ Click: "+ Create collection"
☐ Name: store_fertilizers
☐ Click: "Next"
☐ Click: "Auto ID"
```

### Add Document 1: Shop A sells Urea
```
☐ Add field: storeId (String) = [PASTE SHOP A ID]
☐ Add field: fertilizerId (String) = [PASTE UREA ID]
☐ Add field: price (Number) = 250.0
☐ Add field: stock (Number) = 100
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

### Add Document 2: Shop B sells Urea
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeId (String) = [PASTE SHOP B ID]
☐ Add field: fertilizerId (String) = [PASTE UREA ID]
☐ Add field: price (Number) = 275.0
☐ Add field: stock (Number) = 50
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

### Add Document 3: Shop C sells Urea
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeId (String) = [PASTE SHOP C ID]
☐ Add field: fertilizerId (String) = [PASTE UREA ID]
☐ Add field: price (Number) = 260.0
☐ Add field: stock (Number) = 75
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

### Add Document 4: Shop A sells DAP (Optional)
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeId (String) = [PASTE SHOP A ID]
☐ Add field: fertilizerId (String) = [PASTE DAP ID]
☐ Add field: price (Number) = 1200.0
☐ Add field: stock (Number) = 80
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

### Add Document 5: Shop B sells DAP (Optional)
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeId (String) = [PASTE SHOP B ID]
☐ Add field: fertilizerId (String) = [PASTE DAP ID]
☐ Add field: price (Number) = 1300.0
☐ Add field: stock (Number) = 60
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

### Add Document 6: Shop C sells DAP (Optional)
```
☐ Click: "+ Add document"
☐ Click: "Auto ID"
☐ Add field: storeId (String) = [PASTE SHOP C ID]
☐ Add field: fertilizerId (String) = [PASTE DAP ID]
☐ Add field: price (Number) = 1250.0
☐ Add field: stock (Number) = 50
☐ Add field: isAvailable (Boolean) = true
☐ Click: Save
```

---

## 📋 PHASE 5: VERIFICATION (Before Testing)

### Check Collections Created
```
☐ See fertilizer_master collection in left menu
☐ See stores collection in left menu
☐ See store_fertilizers collection in left menu
```

### Check fertilizer_master Data
```
☐ Open fertilizer_master
☐ See Urea document
☐ See DAP document (if added)
☐ All fields visible
☐ is_active = true
```

### Check stores Data
```
☐ Open stores
☐ See Shop A document (ABC Fertilizer)
☐ See Shop B document (XYZ Agri)
☐ See Shop C document (Green House)
☐ All shops have isVerified = true
☐ All shops have valid coordinates (not 0,0)
```

### Check store_fertilizers Data
```
☐ Open store_fertilizers
☐ See 3+ documents
☐ Each document has:
  ☐ storeId (matches a shop ID)
  ☐ fertilizerId (matches a fertilizer ID)
  ☐ price (different for each shop)
  ☐ stock (> 0)
  ☐ isAvailable (= true)
```

### Data Type Verification
```
☐ All storeId fields are String type
☐ All fertilizerId fields are String type
☐ All price fields are Number type (NOT String!)
☐ All stock fields are Number type
☐ All isAvailable fields are Boolean type
☐ All latitude/longitude are Number type
☐ All rating/total_reviews are Number type
```

### ID Matching Verification
```
☐ Every storeId in store_fertilizers matches a stores document ID
☐ Every fertilizerId in store_fertilizers matches a fertilizer_master document ID
☐ No typos in copied IDs
☐ No extra spaces in IDs
```

---

## 📋 PHASE 6: TEST (2 min)

### Restart App
```
☐ Close Kisan Mitra app completely
☐ Reopen Kisan Mitra app
☐ Wait for app to load
```

### Login and Navigate
```
☐ Login as Farmer
☐ Go to: Fertilizer Search
```

### Search for Fertilizer
```
☐ Type: "Urea"
☐ Press: Enter/Submit
```

### Verify Results
```
☐ See Shop A: ABC Fertilizer
  ☐ Shows name ✅
  ☐ Shows rating: 4.8 ✅
  ☐ Shows distance: ~0.5 km ✅
  ☐ Shows price: ₹250.00 ✅
  ☐ Shows stock: IN STOCK ✅
  ☐ Navigate button works ✅

☐ See Shop B: XYZ Agri Supplies
  ☐ Shows name ✅
  ☐ Shows rating: 4.5 ✅
  ☐ Shows distance: ~1.2 km ✅
  ☐ Shows price: ₹275.00 ✅ (DIFFERENT!)
  ☐ Shows stock: IN STOCK ✅
  ☐ Navigate button works ✅

☐ See Shop C: Green Fertilizer House
  ☐ Shows name ✅
  ☐ Shows rating: 4.2 ✅
  ☐ Shows distance: ~0.8 km ✅
  ☐ Shows price: ₹260.00 ✅ (DIFFERENT!)
  ☐ Shows stock: IN STOCK ✅
  ☐ Navigate button works ✅
```

### Check Console (Optional)
```
☐ Open Android Logcat
☐ Search for: "DEBUG: Found store_fertilizer"
☐ Should see:
  "Found store_fertilizer: storeId=..., price=250.0"
  "Found store_fertilizer: storeId=..., price=275.0"
  "Found store_fertilizer: storeId=..., price=260.0"
```

---

## 🎉 FINAL STATUS

```
☐ All collections created
☐ All documents added
☐ All data types correct
☐ All IDs matching
☐ App shows shop names ✅
☐ App shows different prices ✅
☐ App shows ratings and distances ✅
☐ Navigation works ✅

TOTAL TIME: ~15 minutes
STATUS: COMPLETE! 🚀
```

---

## 📝 NOTES

**If any step fails:**
- Check the BUILD_COMPLETE_FIREBASE_STRUCTURE.md guide
- Verify all field names are exact
- Verify all data types are correct
- Clear app cache and restart

**Document IDs Reference:**
```
Urea: ___________________________
DAP: ____________________________
Shop A: _________________________
Shop B: _________________________
Shop C: _________________________
```

---

**YOU DID IT! Your fertilizer search now shows different prices from different shops!** ✅

