# Firestore Setup Instructions

## Issue Fixed
The error "permission-denied" was caused by missing Firestore rules for the `safety_guidelines` collection.

## Steps to Deploy the Fix

### 1. Deploy Updated Firestore Rules

#### Option A: Using Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules` file from your project
5. Paste into the Firebase Console rules editor
6. Click **Publish**

#### Option B: Using Firebase CLI
If you have Firebase CLI installed:
```bash
firebase deploy --only firestore:rules
```

### 2. Add Sample Safety Guidelines Data

Go to Firestore Database → Data tab and create a new collection called `safety_guidelines` with the following documents:

**Document 1:**
```json
{
  "guideline": "Always wear protective gloves and mask when handling fertilizers",
  "order": 1,
  "category": "personal_safety"
}
```

**Document 2:**
```json
{
  "guideline": "Store fertilizers in a cool, dry place away from children and pets",
  "order": 2,
  "category": "storage"
}
```

**Document 3:**
```json
{
  "guideline": "Apply fertilizers during early morning or late evening to avoid heat stress",
  "order": 3,
  "category": "application"
}
```

**Document 4:**
```json
{
  "guideline": "Do not mix different types of fertilizers unless specified",
  "order": 4,
  "category": "application"
}
```

**Document 5:**
```json
{
  "guideline": "Wash hands thoroughly after handling fertilizers",
  "order": 5,
  "category": "personal_safety"
}
```

**Document 6:**
```json
{
  "guideline": "Keep fertilizers away from water sources to prevent contamination",
  "order": 6,
  "category": "environmental"
}
```

### 3. Verify the Fix
After deploying the rules and adding the data:
1. Restart your app
2. Navigate to the Fertilizer Advisory screen
3. The error should be resolved and safety guidelines should display

## What Was Changed

### firestore.rules
Added a new rule for the `safety_guidelines` collection:
```javascript
// Safety guidelines collection - public read for advisory screen
match /safety_guidelines/{guidelineId} {
  allow read: if true; // Public read to show safety guidelines
  allow write: if isSignedIn(); // Authenticated users can manage guidelines
}
```

This allows:
- Anyone to read safety guidelines (public read)
- Only authenticated users to create/update/delete guidelines
