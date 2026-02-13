# ✅ FIXED: Edit Profile Dropdown Error After Google Sign-In

## ❌ Error Message
```
'package:flutter/src/material/dropdown.dart':
Failed assertion: line 1795 pos 10: 'items == null || items.isEmpty
|| value == null || items.where((DropdownMenuItem<T> item) => item.value == (initialValue ?? value)).length == 1'
```

**Error:** Dropdown assertion failed - duplicate or invalid values detected

---

## 🔍 Root Cause

When users sign in with Google, their profile is created with **empty strings (`""`)** for state, city, and village fields instead of `null` or valid values.

### The Problem:
1. Google Sign-In creates profile with empty strings:
   ```javascript
   {
     "state": "",      // ❌ Empty string
     "city": "",       // ❌ Empty string
     "village": ""     // ❌ Empty string
   }
   ```

2. Edit Profile screen tries to set dropdown `value` to `""`
3. Empty string is NOT in the dropdown items list
4. Flutter throws assertion error

---

## ✅ Solution Applied

### Fixed File: `lib/features/farmer/profile/edit_profile_screen.dart`

#### Before (Caused Error):
```dart
setState(() {
  _selectedState = profile?.state;  // ❌ Sets empty string ""
  _selectedCity = profile?.city;    // ❌ Sets empty string ""
});
```

#### After (Fixed):
```dart
setState(() {
  // Validate state - only set if it exists in the states list and is not empty
  if (profile?.state != null && 
      profile!.state.trim().isNotEmpty &&   // ✅ Check not empty
      _states.contains(profile.state)) {    // ✅ Check exists in list
    _selectedState = profile.state;
  } else {
    _selectedState = null;  // ✅ Set to null if invalid
  }

  // Validate city - only set if state is valid and city exists in dropdown
  if (_selectedState != null &&
      profile?.city != null &&
      profile!.city.trim().isNotEmpty &&    // ✅ Check not empty
      _citiesByState.containsKey(_selectedState)) {
    final cities = _citiesByState[_selectedState]!;
    if (cities.contains(profile.city)) {    // ✅ Check exists in list
      _selectedCity = profile.city;
    } else {
      _selectedCity = null;  // ✅ Set to null if invalid
    }
  } else {
    _selectedCity = null;  // ✅ Set to null if invalid
  }
});
```

---

## 🎯 What the Fix Does

### 1. Validates State Field:
- ✅ Checks if state is not null
- ✅ Checks if state is not empty string
- ✅ Checks if state exists in the states list
- ✅ Sets to `null` if any validation fails

### 2. Validates City Field:
- ✅ Checks if city is not null
- ✅ Checks if city is not empty string
- ✅ Checks if state is selected first
- ✅ Checks if city exists in the dropdown list for selected state
- ✅ Sets to `null` if any validation fails

### 3. Prevents Assertion Errors:
- ✅ Dropdown `value` is always either `null` or a valid item from the list
- ✅ No empty strings
- ✅ No invalid values

---

## 🧪 Testing

### Step 1: Hot Reload
```bash
# In terminal where flutter run is running
r
```

### Step 2: Test Edit Profile
1. **Sign in with Google** (if not already signed in)
2. Go to **Profile** tab
3. Click **"Edit Profile"**
4. **Should load successfully** ✅ (no red error screen)
5. Fields should show:
   - Name: From Google account
   - Email: From Google account (read-only)
   - Phone: Empty or from Google
   - State: Dropdown with "Select State" hint
   - City: Dropdown disabled (select state first)
   - Village: Empty text field

### Step 3: Fill Location Details
1. **Select State** from dropdown
2. **Select City** from dropdown (now enabled)
3. **Enter Village** name
4. Click **"Save"**
5. **Should save successfully** ✅

### Step 4: Verify
1. Go back to Profile screen
2. Location should show selected values
3. Click "Edit Profile" again
4. **Dropdowns should show selected values** ✅

---

## 📊 User Scenarios

### Scenario 1: New Google User (Empty Fields)
**Before Fix:**
```
Sign in with Google
  ↓
Profile created with empty strings
  ↓
Click "Edit Profile"
  ↓
❌ RED ERROR SCREEN (Dropdown assertion)
```

**After Fix:**
```
Sign in with Google
  ↓
Profile created with empty strings
  ↓
Click "Edit Profile"
  ↓
✅ Screen loads successfully
  ↓
Dropdowns show hints (no value selected)
  ↓
User can select state, city, village
  ↓
Save profile ✅
```

### Scenario 2: Existing User with Valid Data
**Before & After Fix:**
```
Edit Profile
  ↓
✅ Dropdowns show current values
  ↓
Can change values
  ↓
Save successfully ✅
```

### Scenario 3: User with Invalid City for State
**Example:** State = "Punjab", City = "Mumbai" (Mumbai is in Maharashtra)

**Before Fix:**
```
Edit Profile
  ↓
❌ Tries to set invalid city
  ↓
❌ Assertion error
```

**After Fix:**
```
Edit Profile
  ↓
✅ Validates city against state
  ↓
City doesn't exist in Punjab cities list
  ↓
✅ Sets city to null
  ↓
✅ Shows "Select City" hint
  ↓
User selects valid city for Punjab ✅
```

---

## 🔧 Technical Details

### Dropdown Assertion Requirements:
Flutter's `DropdownButtonFormField` requires:
1. `value` must be `null` OR
2. `value` must exist EXACTLY ONCE in the `items` list

### What Causes Assertion to Fail:
- ❌ `value` is empty string but empty string not in items
- ❌ `value` is a string but items have different strings
- ❌ `value` exists multiple times in items (duplicate values)
- ❌ `value` doesn't exist in items at all

### How Fix Prevents Failures:
- ✅ Always validates value before setting
- ✅ Only sets value if it exists in items list
- ✅ Sets to `null` if validation fails
- ✅ `null` is always a valid value for dropdown

---

## 🎨 UI Behavior After Fix

### When User Opens Edit Profile:

#### If State/City are Empty:
```
STATE: [Select State ▼]        ← Hint shown
CITY:  [Select City ▼]         ← Disabled until state selected
```

#### If State is Valid, City is Empty:
```
STATE: [Punjab ▼]              ← Current value shown
CITY:  [Select City ▼]         ← Enabled, hint shown
```

#### If Both State and City are Valid:
```
STATE: [Punjab ▼]              ← Current value shown
CITY:  [Ludhiana ▼]            ← Current value shown
```

---

## 📝 Code Changes Summary

**File:** `lib/features/farmer/profile/edit_profile_screen.dart`

**Lines Changed:** 145-166

**Changes:**
1. Added `profile!.state.trim().isNotEmpty` check
2. Added `_states.contains(profile.state)` validation
3. Added `profile!.city.trim().isNotEmpty` check
4. Added proper null handling for invalid values

**Impact:**
- ✅ Fixes dropdown assertion error
- ✅ Handles Google Sign-In users correctly
- ✅ Validates state/city combinations
- ✅ Improves data integrity

---

## ⚠️ Important Notes

### For Google Sign-In Users:
- Profile is created with empty strings for location fields
- **MUST fill in location details** before saving profile
- All location fields (state, city, village) are **required**

### For Email/Password Users:
- Location fields filled during signup
- Edit Profile should work normally
- Can change location if needed

### Validation Rules:
1. **State:** Must be selected from dropdown
2. **City:** Must be selected from dropdown (specific to state)
3. **Village:** Must be entered (free text)
4. All three are **required** to save profile

---

## 🐛 Troubleshooting

### Still Getting Error?

#### Check 1: Hot Reload Applied
```bash
# In terminal
r
```
If that doesn't work:
```bash
R  # Capital R for hot restart
```

#### Check 2: Clear State
If dropdown still shows error:
1. Logout from app
2. Login again with Google
3. Try Edit Profile again

#### Check 3: Verify Fix Applied
Open `edit_profile_screen.dart` and check line 145-150:
```dart
if (profile?.state != null && 
    profile!.state.trim().isNotEmpty &&  // ← This should be there
    _states.contains(profile.state)) {
```

If you don't see `.trim().isNotEmpty`, the fix wasn't applied.

---

## ✅ Success Criteria

After the fix, you should be able to:

- [ ] Sign in with Google
- [ ] Navigate to Profile
- [ ] Click "Edit Profile"
- [ ] **Screen loads without red error** ✅
- [ ] Select State from dropdown
- [ ] Select City from dropdown
- [ ] Enter Village name
- [ ] Click "Save"
- [ ] Profile saves successfully
- [ ] Location shows in Profile screen
- [ ] Can edit again without errors

---

## 🎉 Result

**Before Fix:**
- ❌ Red error screen for Google Sign-In users
- ❌ Cannot edit profile
- ❌ Dropdown assertion failure

**After Fix:**
- ✅ Edit Profile loads successfully
- ✅ Dropdowns work correctly
- ✅ Can save location details
- ✅ No assertion errors

---

**Status:** ✅ FIXED  
**Tested:** Ready for testing  
**Applies to:** Google Sign-In users and users with invalid location data

Last Updated: February 13, 2026
