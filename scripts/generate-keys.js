const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const CONFIG_DIR = '/pds/config';
const PLC_KEY_PATH = path.join(CONFIG_DIR, 'plc-rotation-key.json');
const SERVER_KEY_PATH = path.join(CONFIG_DIR, 'server-key.json');

// Ensure config directory exists
if (!fs.existsSync(CONFIG_DIR)) {
  fs.mkdirSync(CONFIG_DIR, { recursive: true });
}

// Generate EC key pair
function generateKeyPair() {
  return crypto.generateKeyPairSync('ec', {
    namedCurve: 'P-256',
    publicKeyEncoding: {
      type: 'spki',
      format: 'der'
    },
    privateKeyEncoding: {
      type: 'pkcs8',
      format: 'der'
    }
  });
}

// Convert key to JWK format
function keyToJwk(keyPair) {
  const privateKey = crypto.createPrivateKey({
    key: keyPair.privateKey,
    format: 'der',
    type: 'pkcs8'
  });
  
  const publicKey = crypto.createPublicKey({
    key: keyPair.publicKey,
    format: 'der',
    type: 'spki'
  });
  
  const privateKeyJwk = privateKey.export({ format: 'jwk' });
  
  return {
    key: privateKeyJwk
  };
}

// Generate keys if they don't exist
if (!fs.existsSync(PLC_KEY_PATH)) {
  console.log('Generating PLC rotation key...');
  const plcKeyPair = generateKeyPair();
  const plcJwk = keyToJwk(plcKeyPair);
  fs.writeFileSync(PLC_KEY_PATH, JSON.stringify(plcJwk, null, 2));
  console.log(`PLC rotation key written to ${PLC_KEY_PATH}`);
}

if (!fs.existsSync(SERVER_KEY_PATH)) {
  console.log('Generating server key...');
  const serverKeyPair = generateKeyPair();
  const serverJwk = keyToJwk(serverKeyPair);
  fs.writeFileSync(SERVER_KEY_PATH, JSON.stringify(serverJwk, null, 2));
  console.log(`Server key written to ${SERVER_KEY_PATH}`);
}

// Set environment variables
process.env.PDS_PLC_ROTATION_KEY_PATH = PLC_KEY_PATH;
process.env.PDS_SERVER_DID_KEY_PATH = SERVER_KEY_PATH;

console.log('Key generation complete');