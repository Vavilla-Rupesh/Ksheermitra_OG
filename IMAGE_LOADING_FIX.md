# Image Loading Fix for ngrok

## Problem
Images stored in `backend\uploads\products\` were returning 404 errors when accessed through ngrok URL `https://7ecfdb353f59.ngrok-free.app`.

Error example:
```
12:26:53.191 IST GET /api/uploads/products/scaled_1000039039-1761112684025-34861890.jpg 404 Not Found
```

## Root Cause
Two issues were identified:
1. **Missing route**: Frontend was requesting images from `/api/uploads/...` but backend only served static files from `/uploads/...`
2. **ngrok browser warning**: ngrok requires a special header `ngrok-skip-browser-warning: true` to bypass its browser warning page for static assets

## Solution Implemented

### Backend Changes (`backend/src/server.js`)

1. **Added dual static file serving**:
   ```javascript
   app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
   app.use('/api/uploads', express.static(path.join(__dirname, '../uploads')));
   ```
   Now images are accessible from both `/uploads/...` and `/api/uploads/...`

2. **Updated CORS and Helmet configuration for ngrok**:
   - Disabled Content Security Policy
   - Added `ngrok-skip-browser-warning` to allowed headers
   - Set cross-origin resource policy to "cross-origin"

3. **Added middleware to set ngrok bypass header**:
   ```javascript
   app.use((req, res, next) => {
     res.setHeader('ngrok-skip-browser-warning', 'true');
     next();
   });
   ```

### Flutter App Changes

1. **Updated `lib/utils/image_helper.dart`**:
   - Added `imageHeaders` getter that includes the ngrok bypass header:
   ```dart
   static Map<String, String> get imageHeaders => {
     'ngrok-skip-browser-warning': 'true',
   };
   ```

2. **Updated all Image.network() calls** in the following screens:
   - `lib/screens/customer/products_screen.dart`
   - `lib/screens/customer/product_selection_screen.dart`
   - `lib/screens/admin/products/product_list_screen.dart`
   
   Added the `headers` parameter:
   ```dart
   Image.network(
     ImageHelper.getImageUrl(product.imageUrl),
     headers: ImageHelper.imageHeaders,
     // ... other parameters
   )
   ```

## How to Apply the Fix

### 1. Restart Backend Server
```bash
cd backend
node src/server.js
```
or
```bash
npm start
```

### 2. Rebuild Flutter App
```bash
cd ksheermitra
flutter clean
flutter pub get
flutter run
```

## Verification

After restarting the backend server, images should now be accessible at:
- `https://7ecfdb353f59.ngrok-free.app/uploads/products/scaled_1000039035-1761113972912-259526072.jpg`
- `https://7ecfdb353f59.ngrok-free.app/api/uploads/products/scaled_1000039035-1761113972912-259526072.jpg`

Both URLs will work correctly with the ngrok bypass header.

## Technical Details

### Image Storage
- Images are stored in: `backend/uploads/products/`
- Database stores relative paths: `/uploads/products/filename.jpg`

### URL Construction
The Flutter app constructs image URLs as follows:
1. Base URL from config: `https://7ecfdb353f59.ngrok-free.app/api`
2. Remove `/api` suffix: `https://7ecfdb353f59.ngrok-free.app`
3. Append image path: `/uploads/products/filename.jpg`
4. Final URL: `https://7ecfdb353f59.ngrok-free.app/uploads/products/filename.jpg`

### ngrok Considerations
- ngrok shows a browser warning page by default for security
- The `ngrok-skip-browser-warning` header bypasses this for legitimate requests
- This header must be sent by the client (Flutter app) with each image request
- The backend also sets this header in responses for compatibility

## Files Modified

### Backend
- `backend/src/server.js`

### Flutter
- `ksheermitra/lib/utils/image_helper.dart`
- `ksheermitra/lib/screens/customer/products_screen.dart`
- `ksheermitra/lib/screens/customer/product_selection_screen.dart`
- `ksheermitra/lib/screens/admin/products/product_list_screen.dart`

## Status
✅ Backend configured to serve images from both `/uploads` and `/api/uploads`
✅ ngrok compatibility headers added
✅ Flutter app updated to send bypass headers with image requests
✅ All image loading widgets updated
✅ No compilation errors

The fix is complete and ready to test after restarting the backend server.

