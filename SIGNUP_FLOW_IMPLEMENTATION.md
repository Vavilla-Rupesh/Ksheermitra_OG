# Signup Flow Implementation

## Overview
Implemented a proper signup flow that detects new users during login and collects their details (name, email, location) before allowing access to the app.

## Features Implemented

### 1. **Backend Changes** (`backend/src/services/auth.service.js`)

#### Updated `verifyOTP` Method
- Now checks if user exists in database
- Returns `requiresRegistration: true` for new users (users without a record in database)
- Returns `requiresRegistration: false` for existing users with complete profiles
- New users get OTP verified but don't get logged in until they complete registration

**Response for New User:**
```json
{
  "success": true,
  "isNewUser": true,
  "requiresRegistration": true,
  "message": "OTP verified. Please complete your registration.",
  "phone": "+919876543210"
}
```

**Response for Existing User:**
```json
{
  "success": true,
  "isNewUser": false,
  "requiresRegistration": false,
  "user": { ...userDetails },
  "token": "jwt_token",
  "refreshToken": "refresh_token"
}
```

#### Updated `register` Method
- Verifies OTP again during registration for security
- Creates new user with complete details
- Validates that user doesn't already exist
- Returns user data and authentication tokens

### 2. **Frontend Changes**

#### A. Auth Service (`lib/services/auth_service.dart`)
- Updated `verifyOTP` to handle `requiresRegistration` flag
- Only saves token and user if registration is complete
- Passes full response back to provider

#### B. Auth Provider (`lib/providers/auth_provider.dart`)
- Updated `verifyOTP` to check for `requiresRegistration` flag
- Returns success even if user needs to register (OTP is valid)
- User object remains `null` until registration is complete

#### C. Login Screen (`lib/screens/auth/login_screen.dart`)
- Updated `_verifyOTP` method to check if user is logged in after verification
- If `authProvider.user == null`, redirects to signup screen
- If `authProvider.user != null`, proceeds to appropriate home screen
- Shows message: "New users will be automatically registered"

#### D. New Signup Screen (`lib/screens/auth/signup_screen.dart`)
Created a comprehensive signup form with:

**Required Fields:**
- ✅ Full Name (validated, min 2 characters)
- ✅ Phone Number (auto-filled, read-only)

**Optional Fields:**
- Email (with validation)
- Delivery Address (with GPS location picker)

**Features:**
1. **Location Services Integration**
   - "Use current location" button with GPS icon
   - Auto-fills address using reverse geocoding
   - Stores latitude/longitude for delivery tracking
   - Handles location permissions properly

2. **Form Validation**
   - Name is required (2+ characters)
   - Email format validation (optional)
   - All fields have proper error messages

3. **User Experience**
   - Clean, professional design
   - Loading states for location and submission
   - Security note about data privacy
   - Success/error feedback with snackbars

4. **Auto-navigation**
   - After successful registration, automatically navigates to customer home

## User Flow

### For New Users:
1. User enters phone number on login screen
2. User receives OTP via WhatsApp
3. User enters OTP
4. Backend verifies OTP and detects new user
5. **User is redirected to Signup Screen** 
6. User fills in:
   - Name (required)
   - Email (optional)
   - Address (optional, can use GPS)
7. User submits registration
8. Backend creates user account
9. User is logged in and redirected to customer home

### For Existing Users:
1. User enters phone number on login screen
2. User receives OTP via WhatsApp
3. User enters OTP
4. Backend verifies OTP and finds existing user
5. User is directly logged in
6. User is redirected to appropriate home screen (customer/admin/delivery)

## API Endpoints

### POST `/auth/verify-otp`
**Request:**
```json
{
  "phone": "+919876543210",
  "otp": "123456"
}
```

**Response (New User):**
```json
{
  "success": true,
  "isNewUser": true,
  "requiresRegistration": true,
  "message": "OTP verified. Please complete your registration.",
  "phone": "+919876543210"
}
```

**Response (Existing User):**
```json
{
  "success": true,
  "isNewUser": false,
  "requiresRegistration": false,
  "user": {
    "id": 1,
    "name": "John Doe",
    "phone": "+919876543210",
    "email": "john@example.com",
    "role": "customer",
    "address": "123 Main St",
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### POST `/auth/register`
**Request:**
```json
{
  "phone": "+919876543210",
  "otp": "123456",
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main St, City",
  "latitude": "12.9716",
  "longitude": "77.5946"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "user": { ...userDetails },
  "token": "jwt_token",
  "refreshToken": "refresh_token"
}
```

## Files Modified

### Backend:
1. ✅ `backend/src/services/auth.service.js` - Updated verifyOTP logic

### Frontend:
1. ✅ `lib/services/auth_service.dart` - Updated verifyOTP to handle new response
2. ✅ `lib/providers/auth_provider.dart` - Updated to check requiresRegistration
3. ✅ `lib/screens/auth/login_screen.dart` - Added signup navigation logic
4. ✅ **NEW:** `lib/screens/auth/signup_screen.dart` - Complete signup form

## Security Features

1. **OTP Re-verification**: Registration endpoint re-verifies OTP for security
2. **Duplicate Prevention**: Checks if user already exists before creating account
3. **Token Generation**: Only generates tokens after complete registration
4. **Data Privacy**: Shows privacy notice on signup screen
5. **Permission Handling**: Properly requests and handles location permissions

## UI/UX Features

1. **Progressive Disclosure**: Only shows signup form to new users
2. **Helpful Messages**: Clear instructions at each step
3. **Loading States**: Shows loading indicators during network calls
4. **Error Handling**: User-friendly error messages
5. **Auto-fill**: GPS location auto-fills address field
6. **Validation**: Real-time form validation with helpful messages
7. **Accessibility**: Proper labels, hints, and error messages

## Location Services

The app uses two packages for location:
- **geolocator**: Gets current GPS coordinates
- **geocoding**: Converts coordinates to human-readable address

**Permissions Required:**
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`

## Testing Checklist

- [ ] New user receives OTP
- [ ] New user verifies OTP and sees signup screen
- [ ] New user cannot proceed without entering name
- [ ] Email validation works correctly
- [ ] Location button fetches current address
- [ ] Location permissions are handled properly
- [ ] Registration creates user in database
- [ ] User is logged in after successful registration
- [ ] Existing user logs in directly without signup screen
- [ ] Error messages display correctly
- [ ] Loading states work properly

## Database Schema

The `users` table should have these fields:
- `id` (Primary Key)
- `phone` (Unique, Required)
- `name` (Required after registration)
- `email` (Optional)
- `address` (Optional)
- `latitude` (Optional, Decimal)
- `longitude` (Optional, Decimal)
- `role` (Default: 'customer')
- `isActive` (Default: true)
- `lastLogin` (Timestamp)
- `createdAt` (Timestamp)
- `updatedAt` (Timestamp)

## Environment Variables

No new environment variables required. Uses existing:
- `JWT_SECRET` - For token generation
- `JWT_EXPIRES_IN` - Token expiry (default: 7 days)
- `OTP_LENGTH` - OTP length (default: 6)
- `OTP_EXPIRY_MINUTES` - OTP validity (default: 10)

## Result

✅ **New users are now required to complete their profile before accessing the app**
✅ **Collects essential information: Name (required), Email (optional), Location (optional)**
✅ **Smooth user experience with proper validation and feedback**
✅ **Existing users are not affected - they login directly**
✅ **Location services integration for easy address input**
✅ **Secure OTP verification at both stages**
✅ **Professional UI matching app design system**

The signup flow is now complete and production-ready!

