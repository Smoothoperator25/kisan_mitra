# Fix: "Error loading farmers" in Admin Data Management Screen

## Problem

The Admin Data Management screen was showing "Error loading farmers" when trying to display the list of registered farmers.

## Root Causes

### 1. **Incorrect Collection Name**
- **Issue:** The `AdminDataController` was querying a `'farmers'` collection that doesn't exist
- **Reality:** Farmers are stored in the `'users'` collection with `role: 'farmer'`
- **Fix:** Updated query to use `'users'` collection with role filter

### 2. **Missing Composite Index**
- **Issue:** The query requires a Firestore composite index for `role` + `createdAt`
- **Fix:** Created documentation to guide index creation

### 3. **Data Model Mismatch**
- **Issue:** Models expected fields that didn't match actual Firestore data structure
- **Fix:** Updated models to match actual data

---

## Changes Made

### File: `lib/features/admin/data/admin_data_controller.dart`

#### 1. Fixed Farmers Query
```dart
// BEFORE:
Stream<List<FarmerData>> getFarmersStream() {
  return _firestore
      .collection('farmers')  // ❌ Wrong collection
      .orderBy('createdAt', descending: true)
      .snapshots()
      ...
}

// AFTER:
Stream<List<FarmerData>> getFarmersStream() {
  return _firestore
      .collection('users')  // ✅ Correct collection
      .where('role', isEqualTo: 'farmer')  // ✅ Filter by role
      .orderBy('createdAt', descending: true)
      .snapshots()
      .handleError((error) { ... })  // ✅ Added error handling
      ...
}
```

#### 2. Fixed getFarmerById Method
```dart
// BEFORE:
Future<FarmerData?> getFarmerById(String id) async {
  final doc = await _firestore.collection('farmers').doc(id).get();
  ...
}

// AFTER:
Future<FarmerData?> getFarmerById(String id) async {
  final doc = await _firestore.collection('users').doc(id).get();
  ...
}
```

### File: `lib/features/admin/data/admin_data_model.dart`

#### 1. Fixed FarmerData Model
```dart
factory FarmerData.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>?;
  
  // ✅ Added null check
  if (data == null) {
    throw Exception('Document data is null');
  }

  // ✅ Better error handling for crops field
  List<Crop> cropsList = [];
  if (data['crops'] != null && data['crops'] is List) {
    final cropsData = data['crops'] as List<dynamic>;
    cropsList = cropsData
        .map((crop) {
          try {
            return Crop.fromMap(crop as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing crop: $e');
            return null;
          }
        })
        .whereType<Crop>()
        .toList();
  }

  return FarmerData(
    id: doc.id,
    name: data['name']?.toString() ?? 'Unknown',  // ✅ Better defaults
    // ... other fields
  );
}
```

#### 2. Fixed StoreData Model
```dart
// BEFORE:
class StoreData {
  final String status;  // ❌ Expected string field
  
  factory StoreData.fromFirestore(DocumentSnapshot doc) {
    return StoreData(
      status: data['verificationStatus']?.toString() ?? 'PENDING',
      // ❌ Field doesn't exist in Firestore
    );
  }
}

// AFTER:
class StoreData {
  final bool isVerified;  // ✅ Actual boolean fields
  final bool isRejected;
  
  factory StoreData.fromFirestore(DocumentSnapshot doc) {
    return StoreData(
      isVerified: data['isVerified'] as bool? ?? false,
      isRejected: data['isRejected'] as bool? ?? false,
      // ✅ Matches actual Firestore data
    );
  }
  
  // ✅ Computed property for status
  String get status {
    if (isRejected) return 'REJECTED';
    if (isVerified) return 'VERIFIED';
    return 'PENDING';
  }
}
```

---

## How to Complete the Fix

### Step 1: Create Firestore Composite Index

The query now needs a composite index. You have two options:

**Option A: Automatic (Easiest)**
1. Run the app
2. Login as admin
3. Go to Data Management screen
4. Click "Farmers" tab
5. Firebase will show an error with a **clickable link**
6. Click the link → Firebase Console opens
7. Click "Create Index"
8. Wait 2-5 minutes
9. Refresh the app

**Option B: Manual**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Firestore Database** → **Indexes**
4. Click **"Create Index"**
5. Enter:
   - Collection ID: `users`
   - Field 1: `role` → Ascending
   - Field 2: `createdAt` → Descending
   - Query scope: Collection
6. Click "Create"
7. Wait for status to change from "Building" to "Enabled"

See `FIRESTORE_INDEX_SETUP.md` for detailed instructions.

---

## Testing

After creating the index, test the following:

### 1. Farmers Tab
```
✅ Navigate to: Admin → Data Management → Farmers
✅ Expected: List of all registered farmers
✅ Shows: Name, phone, location, crops (if any)
✅ Search works
✅ No errors
```

### 2. Stores Tab
```
✅ Navigate to: Admin → Data Management → Stores
✅ Expected: List of all registered stores
✅ Shows: Store name, owner, location, status badge
✅ Status badges: PENDING (yellow), VERIFIED (green), REJECTED (red)
✅ Search works
✅ No errors
```

### 3. Error Handling
```
✅ If no farmers exist: Shows "No farmers found"
✅ If no stores exist: Shows "No stores found"
✅ If search has no results: Shows "No [farmers/stores] found"
✅ Loading indicators work correctly
```

---

## Data Structure Reference

### Users Collection (Farmers)
```javascript
{
  "uid": "user123",
  "name": "Farmer Name",
  "email": "farmer@example.com",
  "phone": "9876543210",
  "role": "farmer",  // Important for filtering
  "state": "State Name",
  "city": "City Name",
  "village": "Village Name",
  "crops": [  // Optional field
    {
      "name": "Wheat",
      "acres": 5.0
    }
  ],
  "isActive": true,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Stores Collection
```javascript
{
  "uid": "store123",
  "storeName": "Store Name",
  "ownerName": "Owner Name",
  "email": "store@example.com",
  "phone": "9876543210",
  "role": "store",
  "state": "State Name",
  "city": "City Name",
  "village": "Village Name",
  "location": {
    "latitude": 20.5937,
    "longitude": 78.9629
  },
  "license": "ABC123456789",
  "isVerified": false,  // Used for filtering
  "isRejected": false,  // Used for filtering
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## Summary

✅ **Fixed incorrect collection queries** (farmers → users)  
✅ **Added role-based filtering** for farmers  
✅ **Updated data models** to match Firestore structure  
✅ **Added error handling** to prevent crashes  
✅ **Created index documentation** for easy setup  

**Next Step:** Create the Firestore composite index following the instructions in `FIRESTORE_INDEX_SETUP.md`

Once the index is created and enabled, the "Error loading farmers" issue will be completely resolved! 🎉
