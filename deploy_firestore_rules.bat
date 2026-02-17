@echo off
echo ============================================
echo   Deploy Firestore Rules to Firebase
echo ============================================
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Firebase CLI is not installed!
    echo.
    echo Please install it first:
    echo    npm install -g firebase-tools
    echo.
    pause
    exit /b 1
)

echo Firebase CLI found!
echo.

REM Navigate to project directory
cd /d "%~dp0"
echo Current directory: %cd%
echo.

echo Step 1: Checking Firebase login status...
firebase projects:list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo You are not logged in to Firebase.
    echo.
    echo Opening browser for login...
    firebase login
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Firebase login failed!
        pause
        exit /b 1
    )
)

echo.
echo Step 2: Deploying Firestore rules...
echo.
firebase deploy --only firestore:rules

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo   SUCCESS! Rules deployed successfully!
    echo ============================================
    echo.
    echo Please wait 1-2 minutes for rules to take effect.
    echo Then restart your app and test again.
    echo.
) else (
    echo.
    echo ============================================
    echo   ERROR: Deployment failed!
    echo ============================================
    echo.
    echo Please check:
    echo 1. Internet connection
    echo 2. Firebase project is initialized
    echo 3. You have admin access to the project
    echo.
    echo Try manually:
    echo    firebase deploy --only firestore:rules
    echo.
)

pause

