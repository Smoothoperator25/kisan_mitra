# 🧪 Testing Guide: Stats Count & Pixel Overflow Fix

## ✅ What Was Fixed

1. **Statistics Count Issue** - Stats now query the correct collection (`users` with role filter)
2. **Pixel Overflow Error** - Header is now responsive and won't overflow

---

## 🚀 How to Test

### Step 1: Run the App

```bash
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra
flutter run
```

**Or if app is already running:**
```bash
# Press 'R' in the terminal to hot restart
R
```

---

### Step 2: Login as Admin

**Credentials:**
- Username: `admin`
- Password: `admin123@`

---

### Step 3: Check Dashboard Statistics

You should now see **actual numbers** instead of zeros:

#### ✅ Expected Result:
```
TOTAL FARMERS: [number]  ← Should show actual farmer count
TOTAL STORES: [number]   ← Should show actual store count
PENDING: [number]        ← Should show pending verifications
VERIFIED: [number]       ← Should show verified stores
```

#### ❌ If Still Showing Zeros:

**Option A: No Data Yet**
- You might not have any farmers or stores registered yet
- Register at least 1 farmer and 1 store to see counts

**Option B: Firestore Index Needed**
The farmers query requires a Firestore composite index.

**Quick Fix:**
1. In admin dashboard, go to **DATA** tab (bottom navigation)
2. Click **"Manage Farmers"**
3. You'll see an error with a **blue clickable link**
4. Click it → Firebase Console opens
5. Click **"Create Index"** button
6. Wait 2-5 minutes for index to build
7. Restart the app

**Manual Index Creation:**
- Collection: `users`
- Field 1: `role` (Ascending)
- Field 2: `createdAt` (Descending)
- Query scope: Collection

See **FIRESTORE_INDEX_SETUP.md** for detailed instructions.

---

### Step 4: Test Pixel Overflow Fix

**What to Check:**
- The header should **NOT** show "RIGHT OVERFLOWED BY X PIXELS" warning
- All header elements should fit properly on screen:
  - "Admin Dashboard" text
  - "SECURE" badge
  - Wrench icon (🔧)
  - Notification bell icon (🔔)

**Test on Different Screen Sizes:**
1. Resize the emulator/app window
2. Rotate device (portrait/landscape)
3. All elements should adjust without overflow

---

### Step 5: Test Real-Time Updates

**Purpose:** Verify that statistics update automatically

**Steps:**
1. Note the current **PENDING** count (e.g., 3)
2. Open another device/browser or use Firebase Console
3. Register a new store OR approve a pending store
4. **Within 1-2 seconds**, the stats should update automatically
5. No need to click refresh!

**Expected Behavior:**
- New store registered → **PENDING** increases by 1
- Store approved → **VERIFIED** increases by 1, **PENDING** decreases by 1
- New farmer registered → **TOTAL FARMERS** increases by 1

---

### Step 6: Test Refresh Button

**Location:** Next to "DASHBOARD STATISTICS" heading

**Steps:**
1. Click the **"Refresh"** button (🔄)
2. Statistics should reload immediately
3. No errors should appear

---

### Step 7: Test Fix Database Button

**Location:** Wrench icon (🔧) in top-right corner

**Steps:**
1. Click the wrench icon
2. Dialog appears: "Fix Database"
3. Click **"Fix Database"** button
4. Notification appears: "Fixing database..."
5. Success notification: "✅ Database fixed! Statistics should update now."
6. Stats should refresh automatically

**What It Does:**
- Adds missing `isVerified` and `isRejected` fields to stores
- Fixes old stores that were created before verification system

---

### Step 8: Test Logout

**Steps:**
1. Go to **SETTINGS** tab (bottom navigation)
2. Scroll to bottom
3. Click **"Logout Account"**
4. Confirm logout in dialog
5. **Expected:** Navigate to Admin Login screen (green theme)
6. **Not:** General role selection screen

**Expected Screen After Logout:**
```
┌─────────────────────────────┐
│        🔒 (Lock Icon)       │
│          ADMIN              │
│    (Green Background)       │
│                             │
│   [Username Input]          │
│   [Password Input]          │
│   [LOGIN Button]            │
└─────────────────────────────┘
```

---

## 🔍 Debug Console Logs

**What to Look For:**

When you open the admin dashboard, you should see logs like:

```
🔄 Starting stats stream...
📊 Stats Update - Stores snapshot received: 5 stores
👨‍🌾 Total Farmers: 10
🏪 Total Stores: 5
✅ Verified: 2
⏳ Pending: 3
❌ Rejected: 0
📈 Emitting stats: F=10, S=5, P=3, V=2
```

**If you see:**
```
⚠️ WARNING: 3 stores without status fields - Click Fix Database button!
```
→ Click the wrench icon and run "Fix Database"

---

## ❌ Troubleshooting

### Issue 1: Still Shows All Zeros

**Possible Causes:**
1. No data in Firestore
2. Firestore index not created
3. Internet connection issue
4. Firebase not initialized

**Solutions:**
1. Check Firebase Console → Firestore Database
2. Verify `users` collection has documents with `role: 'farmer'`
3. Verify `stores` collection has documents
4. Create required Firestore index (see Step 3 above)
5. Restart the app completely

---

### Issue 2: Error Message Appears

**Common Errors:**

#### "Error loading stats"
- **Cause:** Firestore query failed
- **Solution:** Check internet connection, verify Firebase configuration

#### "Missing index" or "Requires index"
- **Cause:** Firestore composite index not created
- **Solution:** Click the blue link in error, create index in Firebase Console

#### "Permission denied"
- **Cause:** Firestore security rules blocking read
- **Solution:** Check `firestore.rules` file, ensure admin has read permissions

---

### Issue 3: Pixel Overflow Still Showing

**Solutions:**
1. Hot restart the app (press 'R')
2. If that doesn't work, do a full restart:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### Issue 4: Stats Don't Update in Real-Time

**Check:**
1. Look at debug console for logs
2. Verify stream is emitting: Look for "📈 Emitting stats" logs
3. Check internet connection
4. Try clicking Refresh button manually

**Force Refresh:**
1. Click Refresh button next to "DASHBOARD STATISTICS"
2. Or click wrench icon → Fix Database

---

## 📊 Sample Data for Testing

If you don't have any data, here's how to create test data:

### Register a Test Farmer:
1. Logout from admin
2. Go to Farmer Login → Sign Up
3. Fill in details:
   - Name: Test Farmer
   - Email: farmer@test.com
   - Phone: 9876543210
   - State/City/Village: Any
4. Submit registration
5. Login as admin again
6. **TOTAL FARMERS** should now show 1

### Register a Test Store:
1. Logout from admin
2. Go to Store Login → Registration
3. Fill in details:
   - Store Name: Test Store
   - Owner: Test Owner
   - Phone: 9876543210
   - Upload required documents
4. Submit registration
5. Login as admin again
6. **TOTAL STORES** should show 1
7. **PENDING** should show 1

### Approve the Test Store:
1. In admin dashboard, scroll to "VERIFICATION REQUESTS"
2. Find the test store
3. Click "Approve" button
4. **VERIFIED** should increase to 1
5. **PENDING** should decrease to 0

---

## ✅ Success Criteria

### Statistics Working:
- ✅ Shows actual numbers (not zeros)
- ✅ Updates automatically when data changes
- ✅ Refresh button works
- ✅ Fix Database button works

### Pixel Overflow Fixed:
- ✅ No "OVERFLOWED" warnings
- ✅ Header fits on all screen sizes
- ✅ All elements visible and properly aligned

### Logout Working:
- ✅ Navigates to Admin Login screen
- ✅ Green theme with "ADMIN" title
- ✅ Not the role selection screen

---

## 📝 Test Results Template

Copy this template to track your testing:

```markdown
## Test Results - [Date]

### Statistics Count:
- [ ] TOTAL FARMERS shows correct count
- [ ] TOTAL STORES shows correct count
- [ ] PENDING shows correct count
- [ ] VERIFIED shows correct count
- [ ] Stats update in real-time
- [ ] Refresh button works
- [ ] Fix Database button works

### Pixel Overflow:
- [ ] No overflow warnings
- [ ] Header fits properly
- [ ] Works in portrait mode
- [ ] Works in landscape mode

### Logout:
- [ ] Navigates to Admin Login screen
- [ ] Correct screen appearance

### Debug Logs:
- [ ] Shows farmer count logs
- [ ] Shows store count logs
- [ ] Shows stats emission logs
- [ ] No error messages

### Issues Found:
[List any issues here]

### Notes:
[Any additional observations]
```

---

## 🎉 Expected Final Result

After all fixes, the admin dashboard should:

1. **Display accurate statistics** that match your Firestore data
2. **Update automatically** when data changes (within 1-2 seconds)
3. **Have no pixel overflow errors**
4. **Logout correctly** to admin login screen
5. **Show helpful debug logs** for troubleshooting

**Dashboard should look like:**
```
┌──────────────────────────────────────────┐
│  Admin Dashboard  [SECURE]  🔧 🔔       │  ← No overflow!
│                                          │
│  DASHBOARD STATISTICS       [Refresh]    │
│                                          │
│  ┌─────────┐  ┌─────────┐              │
│  │ FARMERS │  │ STORES  │              │
│  │   10    │  │    5    │  ← Real numbers!
│  └─────────┘  └─────────┘              │
│                                          │
│  ┌─────────┐  ┌─────────┐              │
│  │ PENDING │  │VERIFIED │              │
│  │    3    │  │    2    │  ← Updates live!
│  └─────────┘  └─────────┘              │
└──────────────────────────────────────────┘
```

---

## 🔗 Related Files

- **STATS_COUNT_FIX.md** - Complete fix documentation
- **QUICK_FIX_STATS.md** - Quick reference guide
- **FIRESTORE_INDEX_SETUP.md** - Index creation guide
- **ADMIN_TESTING_GUIDE.md** - General admin testing guide

---

**Last Updated:** February 13, 2026  
**Status:** ✅ Ready for Testing
