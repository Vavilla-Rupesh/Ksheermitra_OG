# Google Maps Setup Guide for Ksheermitra

## Steps to Configure Google Maps API

### 1. Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if building for iOS)
   - Geocoding API
   - Places API (optional, for place search)

4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

### 2. Add API Key to Android

Open `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>
```

### 3. Add API Key to iOS (if needed)

Open `ios/Runner/AppDelegate.swift` and add:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Test the Setup

Run the app and try the signup flow:
1. Click on "Sign Up" from the login screen
2. Fill in your details
3. Click "Current Location" to fetch your location
4. Or click "Pick on Map" to select location on Google Maps

## Troubleshooting

### Maps not loading
- Check that your API key is correct
- Ensure Maps SDK for Android is enabled in Google Cloud Console
- Check that billing is enabled on your Google Cloud account

### Location not working
- Grant location permissions when prompted
- Check that location services are enabled on your device
- Ensure the app has location permissions in device settings

### Geocoding not working
- Enable Geocoding API in Google Cloud Console
- Check API key restrictions if any

## API Key Security

⚠️ **Important**: For production apps, restrict your API key:
1. Go to Google Cloud Console → Credentials
2. Edit your API key
3. Add application restrictions (Android/iOS app restrictions)
4. Add API restrictions (only allow needed APIs)

