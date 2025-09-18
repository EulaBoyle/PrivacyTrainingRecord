# Hello FHEVM: Privacy Training Record Tracker

A beginner-friendly introduction to building decentralized applications (dApps) with Fully Homomorphic Encryption (FHE) using Zama's FHEVM protocol.

## 🎯 What You'll Learn

This tutorial will guide you through building your first privacy-preserving dApp that manages employee training records while keeping sensitive completion status encrypted on-chain.

**Learning Objectives:**
- Understand FHEVM fundamentals without requiring cryptography knowledge
- Build a complete dApp with encrypted smart contract data
- Deploy and interact with FHE-enabled smart contracts
- Create a user-friendly frontend for encrypted data interaction

**Prerequisites:**
- Basic Solidity knowledge (writing and deploying simple smart contracts)
- Familiarity with standard Ethereum tools (Hardhat, MetaMask, React)
- No prior FHE or advanced mathematics knowledge required

## 🌟 Project Overview

### What is FHEVM?

FHEVM (Fully Homomorphic Encryption Virtual Machine) allows smart contracts to perform computations on encrypted data without ever decrypting it. This means sensitive information can remain private while still being processed on-chain.

### The Privacy Training Tracker

Our dApp demonstrates core FHEVM concepts through a practical use case:

**The Problem:** Organizations need to track employee training completion but want to keep individual completion status private while maintaining verifiable records.

**The Solution:** Use FHEVM to encrypt completion status on-chain, allowing:
- Employees to prove training completion without revealing specific details
- Managers to verify training requirements are met
- Audit trails that maintain privacy compliance

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone [your-repository-url]
cd privacy-training-tracker
npm install
```

### 2. Environment Setup

Create a `.env` file:

```bash
PRIVATE_KEY=your_wallet_private_key
INFURA_KEY=your_infura_project_id
```

### 3. Run the Application

```bash
# Start local development server
npm run dev

# Open browser to http://localhost:3000
```

## 📋 Tutorial Steps

### Step 1: Understanding the Smart Contract

Our `PrivacyTrainingRecord.sol` contract demonstrates key FHEVM concepts:

#### Key Features:
- **Encrypted Booleans (`ebool`)**: Store completion status privately
- **Access Control**: Only authorized users can view encrypted data
- **FHE Operations**: Perform operations on encrypted data

#### Code Walkthrough:

```solidity
// Import FHEVM libraries
import {FHE, euint64, eaddress, ebool} from "@fhevm/solidity/lib/FHE.sol";

// Store encrypted completion status
ebool encryptedCompletion;
ebool encryptedCertification;

// Create encrypted boolean values
record.encryptedCompletion = FHE.asEbool(false);
record.encryptedCertification = FHE.asEbool(false);

// Set access permissions
FHE.allow(record.encryptedCompletion, _employee);
FHE.allow(record.encryptedCertification, _employee);
```

### Step 2: Contract Deployment

#### Using Hardhat:

1. **Install Dependencies:**
```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @fhevm/solidity
```

2. **Configure Hardhat (`hardhat.config.js`):**
```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
```

3. **Deploy Script (`scripts/deploy.js`):**
```javascript
async function main() {
  const PrivacyTrainingRecord = await ethers.getContractFactory("PrivacyTrainingRecord");
  const contract = await PrivacyTrainingRecord.deploy();
  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

4. **Run Deployment:**
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Step 3: Frontend Integration

#### Setting Up FHEVM Client:

```javascript
// Initialize FHEVM instance
import { createFhevmInstance } from 'fhevmjs';

const instance = await createFhevmInstance({
  chainId: 9000, // Zama Sepolia testnet
  publicKeyUrl: 'https://gateway.sepolia.zama.ai/fhe-keys'
});
```

#### Encrypting Data Before Sending:

```javascript
async function createTrainingRecord(employeeAddress, employeeName, module) {
  // Connect to contract
  const contract = new ethers.Contract(contractAddress, abi, signer);

  // Create training record
  const tx = await contract.createTrainingRecord(
    employeeAddress,
    employeeName,
    module
  );

  await tx.wait();
  console.log('Training record created successfully');
}
```

#### Decrypting Retrieved Data:

```javascript
async function getCompletionStatus(recordId) {
  // Get encrypted completion status
  const encryptedCompletion = await contract.getEncryptedCompletion(recordId);

  // Decrypt for authorized user
  const completionStatus = await instance.decrypt(contractAddress, encryptedCompletion);

  return completionStatus;
}
```

### Step 4: Testing Your dApp

#### 1. Connect Wallet
- Install MetaMask and connect to Zama Sepolia testnet
- Get test tokens from Zama faucet

#### 2. Create Training Records
- Use the admin interface to create new training records
- Assign training modules to employees

#### 3. Complete Training
- Authorized trainers can mark training as completed
- Completion status is encrypted on-chain

#### 4. View Records
- Employees can view their own training status
- Managers can access records they're authorized to see

## 🔧 Key FHEVM Concepts Explained

### 1. Encrypted Data Types

FHEVM provides encrypted versions of standard data types:

```solidity
ebool encryptedBoolean;     // Encrypted boolean
euint8 encryptedNumber8;    // Encrypted 8-bit number
euint32 encryptedNumber32;  // Encrypted 32-bit number
euint64 encryptedNumber64;  // Encrypted 64-bit number
eaddress encryptedAddress;  // Encrypted address
```

### 2. Creating Encrypted Values

```solidity
// From plaintext (only in smart contract)
ebool encrypted = FHE.asEbool(true);

// From user input (frontend encryption)
// User encrypts data with FHEVM instance before sending
```

### 3. Access Control

```solidity
// Allow specific address to decrypt
FHE.allow(encryptedValue, userAddress);

// Allow contract itself to use encrypted value
FHE.allowThis(encryptedValue);
```

### 4. FHE Operations

```solidity
// Comparison operations
ebool result = FHE.eq(encrypted1, encrypted2);  // Equal
ebool result = FHE.ne(encrypted1, encrypted2);  // Not equal
ebool result = FHE.lt(encrypted1, encrypted2);  // Less than

// Arithmetic operations (for numbers)
euint32 sum = FHE.add(encryptedNum1, encryptedNum2);
euint32 product = FHE.mul(encryptedNum1, encryptedNum2);

// Logical operations (for booleans)
ebool and_result = FHE.and(encryptedBool1, encryptedBool2);
ebool or_result = FHE.or(encryptedBool1, encryptedBool2);
```

## 🛠 Development Environment Setup

### Required Tools:

1. **Node.js** (v16 or later)
2. **npm** or **yarn**
3. **MetaMask** browser extension
4. **Git**

### Installing FHEVM Dependencies:

```bash
# Core FHEVM library
npm install @fhevm/solidity

# Frontend FHEVM client
npm install fhevmjs

# Hardhat for smart contract development
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
```

### Network Configuration:

Add Zama Sepolia testnet to MetaMask:
- **Network Name:** Zama Sepolia Testnet
- **RPC URL:** https://sepolia.zama.ai/
- **Chain ID:** 9000
- **Currency Symbol:** ETH
- **Block Explorer:** https://sepolia.zamascan.io/

## 🎓 Understanding the Code

### Smart Contract Structure:

1. **Data Structures:**
   - `TrainingRecord`: Stores encrypted completion status
   - `TrainingModule`: Defines available training courses
   - Access control mappings for authorization

2. **Key Functions:**
   - `createTrainingRecord()`: Creates new training assignment
   - `completeTraining()`: Marks training as completed (encrypted)
   - `getEncryptedCompletion()`: Retrieves encrypted completion status

3. **Security Features:**
   - Role-based access control
   - Encrypted sensitive data
   - Proper access permission management

### Frontend Architecture:

1. **FHEVM Integration:**
   - Instance creation and management
   - Data encryption before transmission
   - Decryption of authorized data

2. **User Interface:**
   - Admin dashboard for record management
   - Employee view for personal records
   - Trainer interface for completion marking

3. **Wallet Integration:**
   - MetaMask connection
   - Transaction signing
   - Network switching

## 🔍 Testing and Verification

### Manual Testing Steps:

1. **Deploy Contract:**
   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```

2. **Create Training Record:**
   - Connect as admin
   - Create record for test employee
   - Verify record creation event

3. **Complete Training:**
   - Connect as authorized trainer
   - Mark training as completed
   - Verify encryption of completion status

4. **View Encrypted Data:**
   - Connect as employee
   - Decrypt and view completion status
   - Verify access control works correctly

### Automated Testing:

```javascript
describe("PrivacyTrainingRecord", function () {
  it("Should create and complete training record", async function () {
    const [admin, trainer, employee] = await ethers.getSigners();

    // Deploy contract
    const contract = await deployContract();

    // Create training record
    await contract.connect(admin).createTrainingRecord(
      employee.address,
      "John Doe",
      "data-privacy"
    );

    // Complete training
    await contract.connect(trainer).completeTraining(
      0, true, true, 85, "Excellent performance"
    );

    // Verify completion
    const encryptedStatus = await contract.getEncryptedCompletion(0);
    expect(encryptedStatus).to.not.be.undefined;
  });
});
```

## 🚨 Common Issues and Solutions

### 1. "Module not found: @fhevm/solidity"
**Solution:** Install FHEVM dependencies:
```bash
npm install @fhevm/solidity fhevmjs
```

### 2. "Invalid network configuration"
**Solution:** Verify Hardhat network config matches Zama Sepolia settings

### 3. "Transaction reverted: Not authorized"
**Solution:** Ensure wallet address has proper permissions in contract

### 4. "Unable to decrypt data"
**Solution:** Check that user has permission to decrypt the specific encrypted value

### 5. "Contract deployment failed"
**Solution:** Verify sufficient test ETH and correct private key configuration

## 📚 Additional Resources

### FHEVM Documentation:
- [Official FHEVM Docs](https://docs.zama.ai/fhevm)
- [FHEVM Solidity Library](https://github.com/zama-ai/fhevm)
- [FHEVM.js Client Library](https://github.com/zama-ai/fhevmjs)

### Development Tools:
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [MetaMask Developer Docs](https://docs.metamask.io/)

### Community:
- [Zama Discord](https://discord.gg/zama)
- [GitHub Discussions](https://github.com/zama-ai/fhevm/discussions)
- [Developer Forums](https://community.zama.ai/)

## 🎉 Next Steps

After completing this tutorial, you can:

1. **Extend the dApp:**
   - Add more complex encrypted data types
   - Implement encrypted arithmetic operations
   - Create encrypted voting or survey systems

2. **Optimize for Production:**
   - Add comprehensive error handling
   - Implement gas optimization strategies
   - Add automated testing suites

3. **Explore Advanced Features:**
   - Conditional encrypted operations
   - Encrypted computations between multiple parties
   - Integration with other DeFi protocols

4. **Build New Applications:**
   - Encrypted voting systems
   - Private financial applications
   - Confidential identity verification

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for details on how to submit improvements and bug fixes.

---

**Happy Building!** 🚀

You've now learned the fundamentals of building privacy-preserving dApps with FHEVM. This knowledge opens up endless possibilities for creating applications that protect user privacy while maintaining the transparency and verifiability of blockchain technology.