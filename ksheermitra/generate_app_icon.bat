@echo off
echo Installing Flutter packages...
cd C:\Users\MAHESH\Downloads\Ksheer_Mitra-main\Ksheer_Mitra-main\ksheermitra
flutter pub get

echo.
echo Generating app launcher icons...
flutter pub run flutter_launcher_icons

echo.
echo Done! Your app icon has been configured.
pause

