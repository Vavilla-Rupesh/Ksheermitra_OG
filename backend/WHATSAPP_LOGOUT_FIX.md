# WhatsApp Auto-Logout Fix Guide

## Problem
WhatsApp is automatically logging out immediately after connecting (within 1 minute or less).

## Root Causes

### 1. **Multiple Server Instances Running**
- Check if you have multiple terminals running the backend
- WhatsApp detects multiple connections and logs them all out

**Fix:**
```powershell
# Kill all node processes
taskkill /F /IM node.exe

# Wait 5 seconds, then start fresh
npm run dev
```

### 2. **WhatsApp Web Open in Browser**
- If you're logged into web.whatsapp.com in Chrome/Firefox/Edge
- WhatsApp only allows ONE active web session at a time

**Fix:**
- Close ALL browser tabs with WhatsApp Web
- Log out from web.whatsapp.com completely
- Clear browser cache/cookies for WhatsApp Web

### 3. **Multiple Linked Devices on Phone**
- Old/stale linked devices on your WhatsApp app

**Fix:**
1. Open WhatsApp on your phone
2. Settings → Linked Devices
3. **Remove ALL devices** (tap each, select "Log Out")
4. Wait 30 seconds
5. Then scan the new QR code

### 4. **WhatsApp Anti-Bot Detection**
- WhatsApp detects automated behavior patterns
- Too-frequent reconnection attempts trigger logout

**Fix:**
- Wait at least 2-3 minutes between connection attempts
- Don't scan the QR code immediately after logout
- Let the system fully clear the session first

### 5. **Session Corruption**
- Corrupted session data in whatsapp-session folder

**Fix:**
```bash
npm run fix-whatsapp
# This clears the session folder
```

## Complete Fresh Start Procedure

Follow these steps **IN ORDER**:

### Step 1: Stop Everything
```powershell
# Stop the server (Ctrl+C in terminal)
# Then kill any remaining node processes
taskkill /F /IM node.exe
```

### Step 2: Clear WhatsApp Session
```bash
npm run fix-whatsapp
```

### Step 3: Clean Your Phone
1. Open WhatsApp on phone
2. Settings → Linked Devices
3. Remove ALL linked devices
4. Wait 1-2 minutes

### Step 4: Close Browser WhatsApp
1. Close ALL browser tabs with web.whatsapp.com
2. Clear browser cache (Ctrl+Shift+Del)
3. Close the browser completely

### Step 5: Wait
⏰ **Wait 2-3 minutes** - this is critical!
- Let WhatsApp's servers fully clear your old sessions
- Don't rush this step

### Step 6: Start Server
```bash
npm run dev
```

### Step 7: Scan QR Code
1. Wait for QR code to appear in terminal
2. Open WhatsApp on phone
3. Settings → Linked Devices → Link a Device
4. Scan the QR code
5. Wait for "WhatsApp client is ready and connected!"

### Step 8: Don't Touch Anything
- **DO NOT** open WhatsApp Web in browser
- **DO NOT** restart the server unnecessarily
- Let it run and stabilize for 5-10 minutes

## Prevention Tips

### ✅ DO:
- Keep only ONE backend server instance running
- Keep your phone's WhatsApp app updated
- Use a stable internet connection
- Let the session persist (don't restart server frequently)

### ❌ DON'T:
- Open WhatsApp Web in browser while server is running
- Run multiple server instances
- Restart server immediately after logout
- Scan QR code multiple times rapidly
- Use WhatsApp Web on multiple devices

## Checking for Multiple Instances

### Windows PowerShell:
```powershell
# List all node processes
Get-Process node

# Kill all if you see duplicates
taskkill /F /IM node.exe
```

### Alternative Check:
```powershell
# Check what's using port 3000
netstat -ano | findstr :3000

# Kill specific process by PID
taskkill /F /PID <PID_NUMBER>
```

## Still Having Issues?

### Check Logs
The server logs will show why WhatsApp disconnects:
- `LOGOUT` - Manual logout or session conflict
- `NAVIGATION` - WhatsApp Web version mismatch
- `CONFLICT` - Another session is active
- `UNPAIRED` - Phone removed the device

### Try Different Approach
If auto-logout persists after following all steps:

1. **Use a different phone number** (if possible)
   - Some numbers get flagged for automated activity

2. **Wait 24 hours**
   - WhatsApp may have temporarily blocked automated access
   - Try again the next day

3. **Use official WhatsApp Business API** (advanced)
   - More stable for business use
   - Requires approval from Meta

## Technical Details

The improvements made:
- ✅ Reduced keep-alive frequency to avoid detection
- ✅ Removed aggressive puppeteer flags
- ✅ Prevented duplicate event listeners
- ✅ Disabled force takeover on conflict
- ✅ Added duplicate ready event protection
- ✅ Increased delays between reconnection attempts

## Need Help?

If the issue persists:
1. Check the server logs for specific error messages
2. Verify your WhatsApp is not using an old/beta version
3. Ensure stable internet connection on both server and phone
4. Try using a different network (mobile data vs WiFi)

