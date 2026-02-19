@echo off
echo ========================================
echo Developer Photo Setup Checker
echo ========================================
echo.

:: Check if assets folder exists
if exist "assets\images" (
    echo [OK] assets\images folder exists
) else (
    echo [MISSING] assets\images folder not found
    echo Creating folder...
    mkdir assets\images
    echo [CREATED] assets\images folder created
)
echo.

:: Check if developer photo exists
if exist "assets\images\developer_photo.jpg" (
    echo [OK] developer_photo.jpg found
    echo.
    echo File details:
    dir "assets\images\developer_photo.jpg"
    echo.
    echo ========================================
    echo STATUS: Ready to run!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Run: flutter pub get
    echo 2. Run: flutter run
    echo.
) else (
    echo [MISSING] developer_photo.jpg not found
    echo.
    echo ========================================
    echo ACTION REQUIRED!
    echo ========================================
    echo.
    echo Please save the developer photo as:
    echo %cd%\assets\images\developer_photo.jpg
    echo.
    echo Accepted formats: JPG or PNG
    echo Recommended size: 400x400 pixels or higher
    echo.
)

echo.
echo Press any key to exit...
pause > nul

