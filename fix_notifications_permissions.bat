@echo off
echo ===============================================
echo   ADMIN NOTIFICATIONS - FIRESTORE RULES FIX
echo ===============================================
echo.
echo The notification screen requires updated Firestore security rules.
echo.
echo MANUAL FIX REQUIRED:
echo -------------------
echo.
echo 1. Open Firebase Console: https://console.firebase.google.com/
echo.
echo 2. Select your project: kisan_mitra
echo.
echo 3. Go to: Firestore Database ^> Rules
echo.
echo 4. Copy the ENTIRE content from: firestore.rules file
echo.
echo 5. Paste it into the Firebase Console rules editor
echo.
echo 6. Click "Publish" button
echo.
echo 7. Wait 10-15 seconds, then restart your app
echo.
echo ===============================================
echo.
echo Opening firestore.rules file for you to copy...
echo.
timeout /t 3 >nul
notepad firestore.rules
echo.
echo After publishing rules in Firebase Console, press any key to continue...
pause >nul
echo.
echo Done! Now restart your app and test the notifications screen.
echo.
pause
