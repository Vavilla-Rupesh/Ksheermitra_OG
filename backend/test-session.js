/**
 * Test WhatsApp Session Persistence
 *
 * This script checks if WhatsApp session is properly saved
 * Run after successful QR code scan
 */

const fs = require('fs');
const path = require('path');

console.log('');
console.log('='.repeat(60));
console.log('WhatsApp Session Persistence Test');
console.log('='.repeat(60));
console.log('');

const sessionPath = process.env.WHATSAPP_SESSION_PATH || './baileys_auth';
const fullPath = path.resolve(sessionPath);

console.log(`Checking session path: ${fullPath}`);
console.log('');

// Check if directory exists
if (!fs.existsSync(fullPath)) {
  console.log('❌ Session directory does NOT exist');
  console.log('');
  console.log('This means:');
  console.log('  - No QR code has been scanned yet, OR');
  console.log('  - Session was not saved, OR');
  console.log('  - Wrong session path');
  console.log('');
  console.log('Solution:');
  console.log('  1. Start the server: npm run dev');
  console.log('  2. Scan the QR code');
  console.log('  3. Wait for "Session saved" message');
  console.log('  4. Run this test again');
  process.exit(1);
}

console.log('✅ Session directory exists');
console.log('');

// Check for session files
const files = fs.readdirSync(fullPath);

if (files.length === 0) {
  console.log('❌ Session directory is EMPTY');
  console.log('');
  console.log('This means session was not saved properly.');
  console.log('');
  console.log('Solution:');
  console.log('  1. Delete the empty directory');
  console.log('  2. Restart server');
  console.log('  3. Scan QR code again');
  console.log('  4. Wait for "Session saved" message');
  process.exit(1);
}

console.log(`✅ Found ${files.length} session file(s):`);
console.log('');

// Check for critical files
const hasCreds = files.some(f => f === 'creds.json');
const hasAppState = files.some(f => f.startsWith('app-state-sync-key'));
const hasSession = files.some(f => f.startsWith('session-'));

files.forEach(file => {
  const stats = fs.statSync(path.join(fullPath, file));
  const size = (stats.size / 1024).toFixed(2);
  console.log(`  📄 ${file} (${size} KB)`);
});

console.log('');
console.log('='.repeat(60));
console.log('Session File Validation:');
console.log('='.repeat(60));
console.log('');

if (hasCreds) {
  console.log('✅ creds.json found - Contains authentication credentials');
} else {
  console.log('❌ creds.json MISSING - Session incomplete!');
}

if (hasAppState) {
  const appStateCount = files.filter(f => f.startsWith('app-state-sync-key')).length;
  console.log(`✅ ${appStateCount} app-state-sync-key file(s) found - Contains sync keys`);
} else {
  console.log('⚠️  app-state-sync-key files missing - May cause issues');
}

if (hasSession) {
  const sessionCount = files.filter(f => f.startsWith('session-')).length;
  console.log(`✅ ${sessionCount} session file(s) found - Contains session data`);
} else {
  console.log('⚠️  session files missing - May cause issues');
}

console.log('');

if (hasCreds) {
  console.log('='.repeat(60));
  console.log('🎉 SESSION IS PROPERLY SAVED!');
  console.log('='.repeat(60));
  console.log('');
  console.log('This means:');
  console.log('  ✅ You can restart the server without scanning QR again');
  console.log('  ✅ Session will persist across restarts');
  console.log('  ✅ Connection will be automatic on next start');
  console.log('');
  console.log('Test it:');
  console.log('  1. Stop the server (Ctrl+C)');
  console.log('  2. Start it again: npm run dev');
  console.log('  3. Should connect WITHOUT QR code!');
  console.log('');
} else {
  console.log('='.repeat(60));
  console.log('⚠️  SESSION IS INCOMPLETE');
  console.log('='.repeat(60));
  console.log('');
  console.log('The session directory exists but critical files are missing.');
  console.log('');
  console.log('Solution:');
  console.log('  1. Run: npm run fix-whatsapp');
  console.log('  2. Start server: npm run dev');
  console.log('  3. Scan QR code');
  console.log('  4. Wait for "Session saved" message');
  console.log('  5. Run this test again');
  console.log('');
}

console.log('='.repeat(60));
console.log('');

