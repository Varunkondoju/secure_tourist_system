const { ethers } = require("ethers");

const provider = new ethers.JsonRpcProvider(
  process.env.SEPOLIA_RPC_URL
);

const wallet = new ethers.Wallet(
  process.env.BLOCKCHAIN_PRIVATE_KEY,
  provider
);

const contract = new ethers.Contract(
  process.env.AUDIT_CONTRACT_ADDRESS,
  [
    "event LogEvent(string action,string userHash,string actorHash,uint256 timestamp)",
    "function logEvent(string action,string userHash,string actorHash)"
  ],
  wallet
);

async function logToBlockchain(action, userHash, actorHash) {
  const tx = await contract.logEvent(
    action,
    userHash,
    actorHash
  );
  await tx.wait();
  console.log("Blockchain event sent:", action);
}

module.exports = { logToBlockchain };
