/**
 * WhatsApp Session Fix Script
 *
 * Run this script if you're experiencing automatic logouts or connection issues.
 * This will clear the session data and allow you to reconnect fresh.
 *
 * Usage: node fix-whatsapp-session.js
 */

const fs = require('fs');
const path = require('path');

console.log('');
console.log('='.repeat(60));
console.log('WhatsApp Session Fix Script (Baileys)');
console.log('='.repeat(60));
console.log('');

// Clear both old and new session paths
const oldSessionPath = './whatsapp-session';
const newSessionPath = process.env.WHATSAPP_SESSION_PATH || './baileys_auth';
const paths = [oldSessionPath, newSessionPath, './.wwebjs_auth', './.wwebjs_cache'];

let clearedAny = false;

for (const sessionPath of paths) {
  const fullPath = path.resolve(sessionPath);
  console.log(`Checking: ${fullPath}`);

  if (fs.existsSync(fullPath)) {
    console.log('Found existing data. Removing...');

    try {
      fs.rmSync(fullPath, { recursive: true, force: true, maxRetries: 5, retryDelay: 1000 });
      console.log('✅ Cleared successfully!');
      clearedAny = true;
    } catch (error) {
      console.log('❌ Could not clear automatically.');
      console.log(`Error: ${error.message}`);
      console.log('');
      console.log('Please manually delete this folder:');
      console.log(fullPath);
    }
  } else {
    console.log('Not found - OK');
  }
  console.log('');
}

if (!clearedAny) {
  console.log('No session data found to clear.');
}

console.log('');
console.log('='.repeat(60));
console.log('NEXT STEPS:');
console.log('='.repeat(60));
console.log('');
console.log('1. IMPORTANT: On your phone, open WhatsApp');
console.log('   Go to Settings > Linked Devices');
console.log('   Remove ALL existing linked devices');
console.log('');
console.log('2. Start the backend server:');
console.log('   npm run dev');
console.log('');
console.log('3. Scan the NEW QR code with your phone');
console.log('   (WhatsApp > Linked Devices > Link a Device)');
console.log('');
console.log('4. Wait for "WhatsApp connected successfully!"');
console.log('');
console.log('='.repeat(60));
console.log('');
console.log('WHAT CHANGED?');
console.log('');
console.log('✅ Replaced whatsapp-web.js with Baileys');
console.log('✅ NO MORE PUPPETEER - lighter & more stable');
console.log('✅ Better session management');
console.log('✅ Faster connection & reconnection');
console.log('✅ More reliable WhatsApp integration');
console.log('');
console.log('Baileys is a lightweight WhatsApp Web API that connects');
console.log('directly without browser automation, making it much more');
console.log('stable and less likely to be logged out automatically.');
console.log('');

