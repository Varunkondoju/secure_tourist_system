const crypto = require("crypto");

const ALGO = "aes-256-gcm"; // strong + authenticated
const IV_LEN = 12; // recommended for GCM

function encrypt(text, secret) {
  const iv = crypto.randomBytes(IV_LEN);
  const key = crypto.createHash("sha256").update(secret).digest(); // 32 bytes
  const cipher = crypto.createCipheriv(ALGO, key, iv);

  const encrypted = Buffer.concat([cipher.update(text, "utf8"), cipher.final()]);
  const tag = cipher.getAuthTag();

  // iv:tag:ciphertext
  return `${iv.toString("hex")}:${tag.toString("hex")}:${encrypted.toString("hex")}`;
}

function decrypt(payload, secret) {
  const [ivHex, tagHex, dataHex] = payload.split(":");
  const iv = Buffer.from(ivHex, "hex");
  const tag = Buffer.from(tagHex, "hex");
  const data = Buffer.from(dataHex, "hex");
  const key = crypto.createHash("sha256").update(secret).digest();

  const decipher = crypto.createDecipheriv(ALGO, key, iv);
  decipher.setAuthTag(tag);
  const decrypted = Buffer.concat([decipher.update(data), decipher.final()]);
  return decrypted.toString("utf8");
}

module.exports = { encrypt, decrypt };
function hashPII(text) {
  return crypto.createHash("sha256").update(text).digest("hex");
}

module.exports = { encrypt, decrypt, hashPII };

