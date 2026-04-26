#!/usr/bin/env node

/**
 * Manual Test Script for WhatsApp Admin QR Code Login Feature
 *
 * Usage: node test-whatsapp-login.js
 *
 * This script allows you to manually test all WhatsApp login endpoints
 */

const http = require('http');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (prompt) => {
  return new Promise(resolve => {
    rl.question(prompt, resolve);
  });
};

// Configuration
const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';
const USERNAME = process.env.WHATSAPP_ADMIN_USERNAME || 'admin';
const PASSWORD = process.env.WHATSAPP_ADMIN_PASSWORD || 'password';

// Helper function to make HTTP requests
function makeRequest(method, endpoint, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${BASE_URL}/api${endpoint}`);

    // Create Basic Auth header
    const credentials = Buffer.from(`${USERNAME}:${PASSWORD}`).toString('base64');

    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', chunk => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            body: JSON.parse(data)
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            body: data
          });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

async function displayMenu() {
  console.log('\n=== WhatsApp Admin QR Code Login - Test Suite ===\n');
  console.log('1. Get QR Code for WhatsApp Login');
  console.log('2. Get Session Status');
  console.log('3. Get Detailed Session Info');
  console.log('4. Reset WhatsApp Session');
  console.log('5. Exit\n');

  return question('Select option (1-5): ');
}

async function testGetQRCode() {
  console.log('\n📱 Getting QR Code...');
  try {
    const response = await makeRequest('POST', '/whatsapp-login/get-qr');

    console.log(`\nStatus: ${response.status}`);
    console.log('Response:', JSON.stringify(response.body, null, 2));

    if (response.body.success && response.body.data.qrCode) {
      console.log('\n✅ QR Code generated successfully!');
      console.log(`Session ID: ${response.body.data.qrCode}`);
      console.log('\nInstructions:');
      response.body.data.instructions.forEach((instruction, index) => {
        console.log(`  ${index + 1}. ${instruction}`);
      });
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function testGetStatus() {
  console.log('\n📊 Getting Session Status...');
  try {
    const response = await makeRequest('GET', '/whatsapp-login/status');

    console.log(`\nStatus: ${response.status}`);
    console.log('Response:', JSON.stringify(response.body, null, 2));

    if (response.body.success) {
      const data = response.body.data;
      console.log('\n=== Session Summary ===');
      console.log(`Is Connected: ${data.isConnected ? '✅ Yes' : '❌ No'}`);
      console.log(`Connection State: ${data.connectionState}`);
      if (data.uptime !== null) console.log(`Uptime: ${data.uptime} hours`);
      if (data.timeUntilExpiration !== null) console.log(`Time Until Expiration: ${data.timeUntilExpiration} hours`);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function testGetInfo() {
  console.log('\n📋 Getting Detailed Session Info...');
  try {
    const response = await makeRequest('GET', '/whatsapp-login/info');

    console.log(`\nStatus: ${response.status}`);
    console.log('Response:', JSON.stringify(response.body, null, 2));

    if (response.body.success) {
      const data = response.body.data;
      console.log('\n=== Session Info ===');
      console.log(JSON.stringify(data.session, null, 2));

      console.log('\n=== WhatsApp Status ===');
      console.log(JSON.stringify(data.whatsapp, null, 2));

      console.log('\n=== Expiration Alert ===');
      console.log(JSON.stringify(data.expirationAlert, null, 2));
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function testReset() {
  console.log('\n🔄 Resetting WhatsApp Session...');
  const confirm = await question('Are you sure? This will disconnect and require a new QR scan (yes/no): ');

  if (confirm.toLowerCase() !== 'yes') {
    console.log('Cancelled.');
    return;
  }

  try {
    const response = await makeRequest('POST', '/whatsapp-login/reset');

    console.log(`\nStatus: ${response.status}`);
    console.log('Response:', JSON.stringify(response.body, null, 2));

    if (response.body.success) {
      console.log('\n✅ Session reset successfully!');
      console.log('Next Action: Scan the new QR code (option 1)');
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function main() {
  console.log(`\nConnecting to: ${BASE_URL}`);
  console.log(`Username: ${USERNAME}\n`);

  let running = true;

  while (running) {
    const choice = await displayMenu();

    switch (choice) {
      case '1':
        await testGetQRCode();
        break;
      case '2':
        await testGetStatus();
        break;
      case '3':
        await testGetInfo();
        break;
      case '4':
        await testReset();
        break;
      case '5':
        running = false;
        console.log('\nGoodbye! 👋');
        break;
      default:
        console.log('Invalid option. Please select 1-5.');
    }
  }

  rl.close();
}

main().catch(console.error);

