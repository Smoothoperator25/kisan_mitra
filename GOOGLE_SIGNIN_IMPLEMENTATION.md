# ✅ Google Sign-In Implementation for Farmer Login

## 🎯 What Was Added

### Google Sign-In Feature
A complete Google authentication flow has been added to the Farmer Login screen, allowing users to sign in with their Google accounts.

---

## 📦 Package Added

### pubspec.yaml
```yaml
dependencies:
  google_sign_in: ^6.2.1
```

**Run this command:**
```bash
flutter pub get
```

---

## 🔧 Changes Made

### 1. AuthService (`lib/core/services/auth_service.dart`)

#### Added Import:
```dart
import 'package:google_sign_in/google_sign_in.dart';
```

#### Added Google SignIn Instance:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn();
```

#### Added Sign In with Google Method:
```dart
Future<Map<String, dynamic>> signInWithGoogle() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      return {'success': false, 'message': 'Google sign-in canceled'};
    }

    // Obtain the auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final UserCredential result = await _auth.signInWithCredential(credential);
    
    return {
      'success': true,
      'user': result.user,
      'message': 'Google sign-in successful',
      'isNewUser': result.additionalUserInfo?.isNewUser ?? false,
    };
  } catch (e) {
    return {'success': false, 'message': 'Google sign-in failed. Please try again.'};
  }
}
```

#### Updated Sign Out Method:
```dart
Future<void> signOut() async {
  await Future.wait([
    _auth.signOut(),
    _googleSignIn.signOut(),  // ← Sign out from Google as well
  ]);
}
```

---

### 2. Farmer Login Screen (`lib/features/auth/farmer_login_screen.dart`)

#### Added Import:
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

#### Added Google Sign-In Handler:
```dart
Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  try {
    final result = await _authService.signInWithGoogle();

    if (result['success'] == true) {
      final user = result['user'] as User;
      final isNewUser = result['isNewUser'] as bool;

      if (isNewUser) {
        // New user - create farmer profile
        final createResult = await _firestoreService.createUserDocument(
          uid: user.uid,
          userData: {
            'name': user.displayName ?? 'Farmer',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'state': '',
            'city': '',
            'village': '',
            'profileImageUrl': user.photoURL,
          },
        );

        if (createResult['success'] == true) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppConstants.farmerHomeRoute,
            (route) => false,
          );
        }
      } else {
        // Existing user - verify role
        final firestoreResult = await _firestoreService.getUserRoleAndData(user.uid);

        if (firestoreResult['role'] == AppConstants.roleFarmer) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppConstants.farmerHomeRoute,
            (route) => false,
          );
        } else {
          await _authService.signOut();
          SnackBarHelper.showError(context, 
            'This Google account is registered with a different role.');
        }
      }
    }
  } catch (e) {
    SnackBarHelper.showError(context, 'An error occurred: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Added Google Sign-In Button:
```dart
// After Login button
const SizedBox(height: 16),

// Google Sign-In Button
SizedBox(
  width: double.infinity,
  height: 56,
  child: OutlinedButton.icon(
    onPressed: _isLoading ? null : _handleGoogleSignIn,
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    icon: const Icon(Icons.g_mobiledata_rounded, 
      size: 32, color: Color(0xFF4285F4)),
    label: Text('Sign in with Google',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5F7D63),
      ),
    ),
  ),
),
```

---

## 🔐 Firebase Configuration Required

### Android Setup

#### 1. SHA-1 Certificate Fingerprint
Get your SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

Or for debug:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### 2. Add to Firebase Console
1. Go to Firebase Console → Project Settings
2. Select your Android app
3. Click "Add fingerprint"
4. Paste SHA-1 fingerprint
5. Click "Save"
6. Download new `google-services.json`
7. Replace `android/app/google-services.json`

#### 3. Update `android/app/build.gradle.kts`
Already configured with:
```kotlin
dependencies {
    implementation("com.google.android.gms:play-services-auth:21.0.0")
}
```

### iOS Setup (if targeting iOS)

#### 1. Add URL Scheme
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

Get YOUR-CLIENT-ID from `GoogleService-Info.plist`

---

## 🧪 How to Test

### Step 1: Run flutter pub get
```bash
cd C:\Users\lenovo\AndroidStudioProjects\kisan_mitra
flutter pub get
```

### Step 2: Configure Firebase
1. Add SHA-1 fingerprint to Firebase Console
2. Download new `google-services.json`
3. Replace in `android/app/`

### Step 3: Run the App
```bash
flutter run
```

### Step 4: Test Google Sign-In

#### A. Navigate to Farmer Login
1. Open app
2. Select "Farmer" role
3. See "Sign in with Google" button

#### B. Click Google Sign-In
1. Click "Sign in with Google" button
2. Google account picker appears
3. Select a Google account
4. Grant permissions if prompted

#### C. First-Time User Flow
1. New Google user signs in
2. App creates Firestore profile automatically
3. Profile fields:
   - Name: From Google account
   - Email: From Google account
   - Phone: From Google account (if available)
   - Profile Image: From Google account
   - State/City/Village: Empty (can edit later)
4. Navigates to Farmer Dashboard ✅

#### D. Returning User Flow
1. Existing Google user signs in
2. App verifies role is "farmer"
3. Navigates to Farmer Dashboard ✅

#### E. Wrong Role Flow
1. Google account registered as "store" tries to sign in via farmer login
2. Shows error: "This Google account is registered with a different role."
3. Signs out automatically
4. User remains on login screen ✅

---

## 🎨 UI Design

### Button Appearance:
```
┌─────────────────────────────────┐
│  [Email Input Field]            │
│  [Password Input Field]         │
│  Forgot Password?               │
│                                 │
│  ┌───────────────────────────┐ │
│  │    [Login Button]         │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │  G  Sign in with Google  │ │  ← NEW!
│  └───────────────────────────┘ │
│                                 │
│  Create New Account             │
└─────────────────────────────────┘
```

**Style:**
- White background
- Light gray border
- Blue "G" icon
- Gray text
- Rounded corners (12px)
- Same height as Login button (56px)
- Disabled state when loading

---

## 🔍 User Flow Diagram

```
User clicks "Sign in with Google"
          ↓
Google account picker appears
          ↓
User selects account
          ↓
   ┌──────────────┐
   │  New User?   │
   └──────────────┘
    ↓           ↓
   YES          NO
    ↓           ↓
Create      Check Role
Profile         ↓
    ↓      ┌─────────┐
    ↓      │ Farmer? │
    ↓      └─────────┘
    ↓       ↓      ↓
    ↓      YES     NO
    ↓       ↓      ↓
    ↓       ↓   Error + Sign Out
    ↓       ↓
    └───→ Navigate to Dashboard
```

---

## 📊 Data Stored in Firestore

### New Google User Profile:
```javascript
{
  "uid": "google_user_id",
  "name": "John Doe",           // From Google
  "email": "john@gmail.com",    // From Google
  "phone": "+1234567890",       // From Google (if available)
  "role": "farmer",
  "state": "",                  // Empty - user can fill later
  "city": "",                   // Empty - user can fill later
  "village": "",                // Empty - user can fill later
  "profileImageUrl": "https://...",  // From Google photo
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## ⚠️ Important Notes

### 1. Firebase Configuration
- **Must** add SHA-1 fingerprint to Firebase Console
- **Must** download and replace `google-services.json`
- Without this, Google Sign-In will fail silently

### 2. Internet Required
- Google Sign-In requires active internet connection
- Shows error if offline

### 3. Google Account Permissions
- Requires: Email, Profile, OpenID
- User must grant these permissions
- User can revoke anytime in Google account settings

### 4. Security
- Uses OAuth 2.0
- Tokens managed by Firebase
- Secure credential exchange
- No password stored

### 5. Sign Out
- Signing out signs out from both Firebase AND Google
- Next sign-in will show account picker again

---

## 🐛 Troubleshooting

### Issue 1: "Sign in failed" Error

**Possible Causes:**
1. SHA-1 not added to Firebase Console
2. Old `google-services.json` file
3. Wrong package name in Firebase
4. Google Sign-In not enabled in Firebase Console

**Solutions:**
1. Add SHA-1 fingerprint
2. Download new `google-services.json`
3. Verify package name matches
4. Enable Google Sign-In in Firebase Authentication

### Issue 2: Account Picker Not Showing

**Possible Causes:**
1. Already signed in
2. Only one Google account on device
3. Google Play Services not installed (emulator)

**Solutions:**
1. Sign out first
2. Add another account or use different device
3. Use physical device or emulator with Play Services

### Issue 3: "Account registered with different role"

**Cause:**
User's Google account is already registered as Store or Admin

**Solution:**
User should use the correct login screen (Store Login or Admin Login)

---

## 📱 Platform Support

### ✅ Android
- Fully supported
- Requires Google Play Services
- SHA-1 configuration required

### ✅ iOS
- Fully supported
- URL scheme configuration required
- `GoogleService-Info.plist` required

### ✅ Web
- Supported by google_sign_in package
- Additional web configuration needed

---

## 🔗 Related Files

1. **pubspec.yaml** - Added google_sign_in package
2. **lib/core/services/auth_service.dart** - Google Sign-In logic
3. **lib/features/auth/farmer_login_screen.dart** - UI and button
4. **android/app/google-services.json** - Firebase config (needs update)

---

## ✅ Testing Checklist

- [ ] Run `flutter pub get`
- [ ] Add SHA-1 to Firebase Console
- [ ] Download new `google-services.json`
- [ ] Replace old `google-services.json`
- [ ] Run `flutter clean`
- [ ] Run `flutter run`
- [ ] Test Google Sign-In with new user
- [ ] Test Google Sign-In with existing user
- [ ] Test wrong role scenario
- [ ] Test sign out
- [ ] Test re-sign in

---

## 🎉 Benefits

1. ✅ **Faster Login** - One tap sign-in
2. ✅ **No Password** - No need to remember password
3. ✅ **Auto Profile** - Name, email, photo from Google
4. ✅ **Secure** - OAuth 2.0 authentication
5. ✅ **User-Friendly** - Familiar Google interface
6. ✅ **Cross-Device** - Same account on all devices

---

**Status:** ✅ IMPLEMENTED  
**Requires:** Firebase SHA-1 configuration  
**Ready for:** Testing after Firebase setup

Last Updated: February 13, 2026
