@echo off
echo ======================================
echo   Getting SHA-1 Fingerprint
echo ======================================
echo.

cd /d "%~dp0android"

echo Running gradlew signingReport...
echo.

call gradlew signingReport

echo.
echo ======================================
echo   COPY THE SHA1 FINGERPRINT ABOVE
echo ======================================
echo.
echo Look for lines like:
echo   SHA1: A1:B2:C3:D4:E5:F6...
echo.
echo Copy the SHA1 value and add it to:
echo Firebase Console - Project Settings - Your App - SHA certificate fingerprints
echo.
pause
