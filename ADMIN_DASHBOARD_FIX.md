# Admin Dashboard Error Fix

## Problem
The admin dashboard shows the error:
```
Error loading requests: [cloud_firestore/failed-precondition] 
The query requires an index. You can create it here: https://...
```

## Solution

### Quick Fix (2 minutes):
1. **Copy the link from the error message** - The full error message contains a link that starts with `https://console.firebase.google.com/...`
2. **Click or paste the link in your browser** - This will open Firebase Console with the index pre-configured
3. **Click "Create Index"** button
4. **Wait 1-2 minutes** for the index to build (you'll see a progress indicator)
5. **Restart your app** - The error should be gone!

### Manual Fix (if automatic link doesn't work):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **kisan-mitra-8cc98**
3. Click **Firestore Database** → **Indexes** tab
4. Click **Create Index** button
5. Configure the index:
   - **Collection ID:** `stores`
   - Click **Add Field** and add these 3 fields:
     - Field: `isVerified`, Order: `Ascending`
     - Field: `isRejected`, Order: `Ascending`  
     - Field: `createdAt`, Order: `Descending`
   - **Query scope:** Collection
6. Click **Create Index**
7. Wait for it to build (1-2 minutes)
8. Restart your app

## What This Does
The admin dashboard needs to find stores that are:
- Not yet verified (`isVerified = false`)
- Not rejected (`isRejected = false`)
- Sorted by creation date (newest first)

This complex query requires a composite index in Firestore, which you're creating with the steps above.

## Store Dashboard Status

### ✅ Already Working:
1. **Profile Button** (top-right corner) - Navigates to Profile tab
2. **Update Price & Stock** button - Navigates to Stock tab where you can update inventory
3. **Store Location** button - Navigates to Location tab to update store location

All buttons in the store dashboard are already active and working correctly!

## After Login Fix

The login screen is already configured to navigate to the dashboard after successful authentication. No changes needed.

---

**Summary:** Just create the Firestore index using the link in the error message, wait 2 minutes, and restart the app!
