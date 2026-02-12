# Store Verification Flow - Complete Guide

## ✅ How It Works Now

When a new store registers in the app, the verification request automatically goes to the admin dashboard!

### Registration Flow:
```
1. Store fills registration form (Step 1: Basic Info)
2. Store fills location & verification details (Step 2)
3. Store clicks "Complete Registration"
4. System creates store account with:
   - isVerified: false
   - isRejected: false
   - createdAt: timestamp
5. Store sees: "Store registered successfully! Awaiting verification."
6. Admin dashboard automatically shows this store in "Verification Requests"
```

---

## 🔧 What I Fixed

### Issue:
Previously, when stores registered, they only had `isVerified: false` but were missing `isRejected: false`. This caused them to NOT appear in the admin's verification requests.

### Solution:
Updated `store_registration_screen.dart` to include both fields:

```dart
final storeData = {
  // ...other fields...
  'isVerified': false,    // Not verified yet
  'isRejected': false,    // Not rejected yet
};
```

Now stores appear in admin dashboard immediately after registration!

---

## 📋 Admin Verification Process

### Step 1: Store Registers
- Store completes registration
- Store document created in Firestore with:
  - `isVerified: false`
  - `isRejected: false`
  - All store details (name, location, license, etc.)

### Step 2: Admin Sees Request
- Admin logs in to admin dashboard
- "VERIFICATION REQUESTS" section shows all pending stores
- Each request shows:
  - Store name
  - Owner name
  - Location (City, State)
  - Registration date
  - License number
  - Approve/Reject buttons

### Step 3: Admin Takes Action

**Option A: Approve Store**
1. Admin clicks "Approve" button
2. System updates store document:
   - `isVerified: true`
   - `verifiedAt: timestamp`
3. Admin activity log created: "APPROVED_STORE"
4. Store can now appear in farmer search results
5. Store gets full access to dashboard features

**Option B: Reject Store**
1. Admin clicks "Reject" button
2. System updates store document:
   - `isRejected: true`
   - `rejectedAt: timestamp`
3. Admin activity log created: "REJECTED_STORE"
4. Store will NOT appear in verification requests anymore
5. Store cannot appear in farmer search results

---

## 🔍 Admin Dashboard Query

The admin dashboard uses this Firestore query:

```dart
await firestore
  .collection('stores')
  .where('isVerified', isEqualTo: false)   // Not verified yet
  .where('isRejected', isEqualTo: false)   // Not rejected yet
  .orderBy('createdAt', descending: true)  // Newest first
  .limit(10)                               // Show 10 at a time
  .get();
```

This query requires the Firestore composite index (see HOW_TO_FIX_INDEX_ERROR.md).

---

## 📊 Dashboard Statistics

The admin dashboard shows real-time stats:

1. **TOTAL FARMERS**: Count of all registered farmers
2. **TOTAL STORES**: Count of all registered stores (verified + pending + rejected)
3. **PENDING**: Stores waiting for verification (`isVerified=false && isRejected=false`)
4. **VERIFIED**: Stores that are approved (`isVerified=true`)

---

## 🎯 Store States

A store can be in one of these states:

### 1. **Pending Verification** (Default)
- `isVerified: false`
- `isRejected: false`
- Shows in admin verification requests
- Cannot be found by farmers

### 2. **Verified** (After Approval)
- `isVerified: true`
- `isRejected: false`
- Does NOT show in verification requests
- CAN be found by farmers searching for fertilizers

### 3. **Rejected** (After Rejection)
- `isVerified: false`
- `isRejected: true`
- Does NOT show in verification requests
- Cannot be found by farmers

---

## ⚠️ Important Notes

### For Store Owners:
- After registration, you must wait for admin approval
- You can still access your dashboard while pending
- Update your inventory while waiting
- Once verified, farmers can find your store
- If rejected, contact admin for clarification

### For Admins:
- Check verification requests regularly
- Verify license/GSTIN numbers before approving
- Review store location on map
- Use activity logs to track all actions
- Pending count updates in real-time

---

## 🚀 Testing the Flow

### Test Scenario 1: New Store Registration
1. Create a new store account from Store Registration screen
2. Complete both steps (basic info + location)
3. Click "Complete Registration"
4. ✅ Store should navigate to dashboard
5. ✅ Dashboard should show "Not Verified" status
6. Login to admin dashboard
7. ✅ New store should appear in "VERIFICATION REQUESTS"
8. ✅ PENDING count should increase by 1

### Test Scenario 2: Store Approval
1. Admin logs in
2. Goes to verification requests
3. Clicks "Approve" on a pending store
4. ✅ Store disappears from requests
5. ✅ PENDING count decreases
6. ✅ VERIFIED count increases
7. Login to that store account
8. ✅ Dashboard shows "VERIFIED" badge
9. Login to farmer account
10. ✅ Store appears in fertilizer search results

### Test Scenario 3: Store Rejection
1. Admin logs in
2. Goes to verification requests
3. Clicks "Reject" on a pending store
4. ✅ Store disappears from requests
5. ✅ PENDING count decreases
6. ✅ VERIFIED count stays same
7. Login to that store account
8. ✅ Dashboard shows not verified
9. ✅ Store does NOT appear in farmer searches

---

## 🔄 Future Enhancements

Potential improvements for the verification system:

1. **Email Notifications**
   - Send email when store is approved/rejected
   - Send email to admin when new store registers

2. **Rejection Reasons**
   - Admin can select reason for rejection
   - Store owner can see rejection reason
   - Store can reapply with corrections

3. **Document Upload**
   - Store can upload license/GSTIN photo
   - Admin can view documents before approval
   - Secure storage in Firebase Storage

4. **Verification Levels**
   - Basic Verification (automatic)
   - Manual Verification (admin approval)
   - Premium Verification (paid with extra features)

5. **Bulk Actions**
   - Admin can approve/reject multiple stores at once
   - Export pending stores list to CSV
   - Filter by state/city

---

## 🐛 Troubleshooting

### Store not appearing in verification requests?
- Check if Firestore index is created (see HOW_TO_FIX_INDEX_ERROR.md)
- Verify store has both `isVerified: false` and `isRejected: false`
- Check if `createdAt` timestamp exists
- Restart the app after creating index

### Dashboard shows "No pending verification requests"?
- This is correct if no stores have registered
- Or all stores are either verified or rejected
- Create a test store to verify the flow

### Verification button not working?
- Check admin permissions in Firestore rules
- Verify admin is logged in correctly
- Check browser console for errors
- Ensure Firebase connection is active

---

## 📝 Summary

✅ **Store Registration** → Sets `isVerified: false` + `isRejected: false`  
✅ **Admin Dashboard** → Shows stores with both flags false  
✅ **Approval Action** → Sets `isVerified: true`  
✅ **Rejection Action** → Sets `isRejected: true`  
✅ **Farmer Search** → Only shows verified stores  

The complete flow is now working! Stores automatically appear in admin verification requests after registration. 🎉
