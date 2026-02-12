# Firestore Composite Index Setup

## Required Indexes

Your app requires the following Firestore composite indexes to work properly:

### 1. Farmers Query Index (Data Management Screen)

**Collection:** `users`  
**Fields indexed:**
- `role` (Ascending)
- `createdAt` (Descending)

**Query Scope:** Collection

---

### 2. Stores Verification Query Index (Admin Dashboard)

**Collection:** `stores`  
**Fields indexed:**
- `isVerified` (Ascending)
- `isRejected` (Ascending)
- `createdAt` (Descending)

**Query Scope:** Collection

---

### 3. Fertilizers Query Index (Data Management Screen)

**Collection:** `fertilizers`  
**Fields indexed:**
- `isArchived` (Ascending)
- `createdAt` (Descending)

**Query Scope:** Collection

---

## How to Create Indexes

### Method 1: Automatic (Recommended)

1. Run your app and navigate to the Admin Data Management screen
2. Click on the "Farmers" tab
3. Firebase will show an error with a **clickable link**
4. Click the link - it will open Firebase Console
5. Click "Create Index"
6. Wait 2-5 minutes for the index to build
7. Refresh the app

### Method 2: Manual Creation

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Firestore Database** → **Indexes** tab
4. Click **"Create Index"**
5. Enter the following:

   **For Farmers Index:**
   - Collection ID: `users`
   - Add Field: `role` → Ascending
   - Add Field: `createdAt` → Descending
   - Query scope: Collection
   - Click "Create"

   **For Stores Index (if not already created):**
   - Collection ID: `stores`
   - Add Field: `isVerified` → Ascending
   - Add Field: `isRejected` → Ascending
   - Add Field: `createdAt` → Descending
   - Query scope: Collection
   - Click "Create"

   **For Fertilizers Index:**
   - Collection ID: `fertilizers`
   - Add Field: `isArchived` → Ascending
   - Add Field: `createdAt` → Descending
   - Query scope: Collection
   - Click "Create"

6. Wait for indexes to build (Status: Building → Enabled)
7. Refresh your app

---

## Troubleshooting

### Error: "The query requires an index"

**Solution:** Follow the steps above to create the required index.

### Index Status: "Building" for too long

**Solution:** 
- Small databases: Should complete in 2-5 minutes
- Large databases: Can take up to 30 minutes
- Check the Indexes tab in Firebase Console for status

### Error still shows after creating index

**Solution:**
1. Make sure the index status is "Enabled" (not "Building")
2. Completely close and restart your app
3. Clear app cache if needed

---

## Verification

To verify indexes are working:

1. **Farmers Tab:**
   - Go to Admin → Data Management → Farmers
   - Should load list of all registered farmers
   - No errors should appear

2. **Stores Tab:**
   - Go to Admin → Data Management → Stores
   - Should load list of all registered stores
   - Status badges should show correctly (PENDING/VERIFIED/REJECTED)

3. **Fertilizers Tab:**
   - Go to Admin → Data Management → Fertilizers
   - Should load list of all active fertilizers
   - No errors should appear

4. **Admin Dashboard:**
   - Go to Admin → Dashboard
   - Verification Requests section should show pending stores
   - No "index required" errors

---

## Why These Indexes Are Needed

**Users Collection Index (`role` + `createdAt`):**
- Used by Data Management screen to filter and sort farmers
- Queries: "Show me all users with role='farmer', sorted by newest first"

**Stores Collection Index (`isVerified` + `isRejected` + `createdAt`):**
- Used by Admin Dashboard to find pending verification requests
- Queries: "Show me all stores that are not verified and not rejected, sorted by newest first"

**Fertilizers Collection Index (`isArchived` + `createdAt`):**
- Used by Data Management screen to show active fertilizers
- Queries: "Show me all fertilizers that are not archived, sorted by newest first"

Without these indexes, Firestore cannot efficiently perform these queries and will throw an error.

---

## Index Creation Status Checklist

- [ ] Farmers Index (`users` collection) - Created
- [ ] Farmers Index - Status: Enabled
- [ ] Stores Index (`stores` collection) - Created
- [ ] Stores Index - Status: Enabled
- [ ] Fertilizers Index (`fertilizers` collection) - Created
- [ ] Fertilizers Index - Status: Enabled
- [ ] App tested - Farmers tab loads successfully
- [ ] App tested - Stores tab loads successfully
- [ ] App tested - Fertilizers tab loads successfully
- [ ] App tested - Admin dashboard loads successfully

Once all checkboxes are marked, your app should work without any index errors! ✅
