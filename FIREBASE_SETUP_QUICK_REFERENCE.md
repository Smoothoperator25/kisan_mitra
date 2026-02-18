# ⚡ COMPLETE FIREBASE SETUP - QUICK REFERENCE

## 🎯 What You Need to Create

3 Collections with specific data:

---

## 1️⃣ COLLECTION: fertilizer_master

**Documents to Add:**

### Document: Urea
```
name (String): Urea
category (String): Nitrogenous
npkComposition (String): 46:0:0
description (String): Nitrogen rich fertilizer
image_url (String): https://example.com/urea.jpg
is_active (Boolean): true
```

### Document: DAP
```
name (String): DAP
category (String): Phosphate
npkComposition (String): 18:46:0
description (String): Diammonium Phosphate
image_url (String): https://example.com/dap.jpg
is_active (Boolean): true
```

### Document: Potash
```
name (String): Potash
category (String): Potassium
npkComposition (String): 0:0:60
description (String): Potassium fertilizer
image_url (String): https://example.com/potash.jpg
is_active (Boolean): true
```

**Note:** Write down each document's ID after creating!

---

## 2️⃣ COLLECTION: stores

**Documents to Add:**

### Document: Shop A
```
storeName (String): ABC Fertilizer & Seeds
ownerName (String): Rajesh Kumar
phone (String): 9876543210
city (String): Delhi
state (String): Delhi
latitude (Number): 28.6139
longitude (Number): 77.2090
isVerified (Boolean): true
rating (Number): 4.8
total_reviews (Number): 150
```

### Document: Shop B
```
storeName (String): XYZ Agri Supplies
ownerName (String): Priya Singh
phone (String): 9876543211
city (String): Delhi
state (String): Delhi
latitude (Number): 28.6150
longitude (Number): 77.2100
isVerified (Boolean): true
rating (Number): 4.5
total_reviews (Number): 120
```

### Document: Shop C
```
storeName (String): Green Fertilizer House
ownerName (String): Amit Patel
phone (String): 9876543212
city (String): Delhi
state (String): Delhi
latitude (Number): 28.6160
longitude (Number): 77.2110
isVerified (Boolean): true
rating (Number): 4.2
total_reviews (Number): 85
```

**Note:** Write down each document's ID after creating!

---

## 3️⃣ COLLECTION: store_fertilizers

**After getting IDs from above collections, add these documents:**

### Document 1
```
storeId (String): [COPY SHOP A ID HERE]
fertilizerId (String): [COPY UREA ID HERE]
price (Number): 250.0
stock (Number): 100
isAvailable (Boolean): true
```

### Document 2
```
storeId (String): [COPY SHOP B ID HERE]
fertilizerId (String): [COPY UREA ID HERE]
price (Number): 275.0
stock (Number): 50
isAvailable (Boolean): true
```

### Document 3
```
storeId (String): [COPY SHOP C ID HERE]
fertilizerId (String): [COPY UREA ID HERE]
price (Number): 260.0
stock (Number): 75
isAvailable (Boolean): true
```

### Document 4 (Optional - DAP)
```
storeId (String): [COPY SHOP A ID HERE]
fertilizerId (String): [COPY DAP ID HERE]
price (Number): 1200.0
stock (Number): 80
isAvailable (Boolean): true
```

### Document 5 (Optional - DAP)
```
storeId (String): [COPY SHOP B ID HERE]
fertilizerId (String): [COPY DAP ID HERE]
price (Number): 1300.0
stock (Number): 60
isAvailable (Boolean): true
```

### Document 6 (Optional - DAP)
```
storeId (String): [COPY SHOP C ID HERE]
fertilizerId (String): [COPY DAP ID HERE]
price (Number): 1250.0
stock (Number): 50
isAvailable (Boolean): true
```

---

## 📋 KEY REMINDERS

✅ **MUST DO:**
- [ ] Create fertilizer_master collection
- [ ] Create stores collection (or verify if exists)
- [ ] Create store_fertilizers collection
- [ ] Use EXACT document IDs when linking
- [ ] All prices as Number type (not String)
- [ ] All locations must be verified (isVerified = true)

❌ **MUST NOT DO:**
- Don't use store names as storeId
- Don't use fertilizer names as fertilizerId
- Don't put prices as strings ("250" instead of 250.0)
- Don't use wrong field names (store_id instead of storeId)

---

## ⏱️ SETUP TIME
- Create fertilizer_master: 3 min
- Create stores: 3 min
- Create store_fertilizers: 5 min
- Test: 2 min
- **TOTAL: ~15 minutes**

---

## ✅ EXPECTED RESULT

After setup, search for "Urea":

```
ABC Fertilizer & Seeds       ₹250.00
⭐ 4.8 (150)  📍 0.5 km
✅ IN STOCK               per unit

XYZ Agri Supplies            ₹275.00
⭐ 4.5 (120)  📍 1.2 km
✅ IN STOCK               per unit

Green Fertilizer House       ₹260.00
⭐ 4.2 (85)   📍 0.8 km
✅ IN STOCK               per unit
```

All with **DIFFERENT PRICES** from different shops! ✅

---

**Follow the main guide: BUILD_COMPLETE_FIREBASE_STRUCTURE.md**

