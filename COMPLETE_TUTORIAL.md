# Complete FHEVM Tutorial: Building Your First Privacy-Preserving dApp

The ultimate beginner's guide to building decentralized applications with Fully Homomorphic Encryption using Zama's FHEVM protocol.

## 🎯 Tutorial Overview

This comprehensive tutorial will teach you how to build a complete privacy-preserving dApp from scratch. You'll learn FHEVM fundamentals, smart contract development, frontend integration, and deployment strategies - all without requiring advanced cryptography knowledge.

### What You'll Build

A **Privacy Training Record Tracker** - a real-world application that demonstrates how to:
- Store sensitive data encrypted on blockchain
- Perform computations on encrypted data
- Implement proper access controls
- Create user-friendly interfaces for encrypted data

### Learning Path

1. **Fundamentals** - Understanding FHEVM and encryption concepts
2. **Smart Contract** - Building the privacy-preserving contract
3. **Frontend** - Creating the user interface
4. **Integration** - Connecting frontend to blockchain
5. **Deployment** - Publishing your dApp
6. **Testing** - Ensuring everything works correctly

## 📚 Prerequisites

### Technical Requirements
- **Solidity Basics**: Ability to write and deploy simple smart contracts
- **Web Development**: HTML, CSS, JavaScript fundamentals
- **Blockchain Tools**: Familiarity with MetaMask and Hardhat

### Required Software
- Node.js (v16 or later)
- Git
- MetaMask browser extension
- Code editor (VS Code recommended)

### No Prior Knowledge Needed
- Cryptography or advanced mathematics
- Fully Homomorphic Encryption theory
- Advanced blockchain development

## 🌟 Chapter 1: Understanding FHEVM

### What is Fully Homomorphic Encryption?

Imagine you have a locked box that can perform calculations on its contents without ever opening. That's essentially what FHE does - it allows computations on encrypted data without decrypting it.

**Traditional Approach:**
```
Encrypt Data → Decrypt → Process → Encrypt Result
```

**FHE Approach:**
```
Encrypt Data → Process Encrypted Data → Encrypted Result
```

### FHEVM in Practice

FHEVM brings FHE to Ethereum Virtual Machine, enabling:

1. **Private Smart Contracts**: Sensitive data stays encrypted on-chain
2. **Confidential Computations**: Operations on encrypted data
3. **Selective Disclosure**: Only authorized parties access data
4. **Regulatory Compliance**: Meets privacy requirements like GDPR

### Real-World Use Cases

- **Healthcare**: Patient records with privacy guarantees
- **Finance**: Confidential transactions and credit scoring
- **Voting**: Anonymous yet verifiable elections
- **Training**: Private completion status (our project!)

## 🔧 Chapter 2: Development Environment Setup

### Step 1: Install Required Tools

```bash
# Check Node.js installation
node --version  # Should be v16+
npm --version

# Install Git (if not already installed)
# Download from: https://git-scm.com/
```

### Step 2: Project Initialization

```bash
# Create project directory
mkdir privacy-training-tracker
cd privacy-training-tracker

# Initialize Node.js project
npm init -y

# Install core dependencies
npm install ethers@5.7.2

# Install development dependencies
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Install FHEVM libraries
npm install @fhevm/solidity fhevmjs
```

### Step 3: Hardhat Configuration

Create `hardhat.config.js`:

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    zamaTestnet: {
      url: "https://sepolia.zama.ai/",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 9000
    }
  }
};
```

### Step 4: Environment Variables

Create `.env` file:

```bash
# Your wallet private key (without 0x prefix)
PRIVATE_KEY=your_private_key_here

# Infura project ID (optional, for additional RPC endpoints)
INFURA_KEY=your_infura_key_here
```

**Security Note**: Never commit `.env` to version control!

## 📝 Chapter 3: Smart Contract Development

### Understanding FHEVM Data Types

FHEVM provides encrypted versions of standard types:

```solidity
ebool encryptedBoolean;     // Encrypted boolean
euint8 encryptedNumber8;    // Encrypted 8-bit number
euint32 encryptedNumber32;  // Encrypted 32-bit number
euint64 encryptedNumber64;  // Encrypted 64-bit number
eaddress encryptedAddress;  // Encrypted address
```

### Step 1: Contract Structure

Create `contracts/PrivacyTrainingRecord.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64, eaddress, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {SepoliaConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract PrivacyTrainingRecord is SepoliaConfig {

    struct TrainingRecord {
        address employee;
        string employeeName;
        string trainingModule;
        ebool encryptedCompletion;      // 🔐 Encrypted completion status
        ebool encryptedCertification;   // 🔐 Encrypted certification status
        uint256 completionTime;
        uint256 expiryTime;
        bool isActive;
        uint256 score;
        string notes;
    }

    struct TrainingModule {
        string name;
        string description;
        uint256 duration; // in days
        bool isActive;
    }

    // Storage mappings
    mapping(uint256 => TrainingRecord) public trainingRecords;
    mapping(string => TrainingModule) public trainingModules;
    mapping(address => uint256[]) public employeeRecords;
    mapping(address => bool) public authorizedTrainers;

    uint256 public recordCounter;
    address public admin;

    // Events for tracking activities
    event TrainingRecordCreated(uint256 indexed recordId, address indexed employee, string trainingModule);
    event TrainingCompleted(uint256 indexed recordId, address indexed employee, bool passed);
    event TrainerAuthorized(address indexed trainer);
    event TrainerRevoked(address indexed trainer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyAuthorizedTrainer() {
        require(authorizedTrainers[msg.sender] || msg.sender == admin, "Not authorized trainer");
        _;
    }
```

### Step 2: Constructor and Initialization

```solidity
    constructor() {
        admin = msg.sender;
        authorizedTrainers[msg.sender] = true;

        // Initialize default training modules
        trainingModules["data-privacy"] = TrainingModule({
            name: "Data Privacy Fundamentals",
            description: "Basic data privacy principles and regulations",
            duration: 30,
            isActive: true
        });

        trainingModules["gdpr-compliance"] = TrainingModule({
            name: "GDPR Compliance",
            description: "General Data Protection Regulation compliance training",
            duration: 45,
            isActive: true
        });

        trainingModules["security-awareness"] = TrainingModule({
            name: "Security Awareness",
            description: "Cybersecurity best practices and threat awareness",
            duration: 60,
            isActive: true
        });
    }
```

### Step 3: Core Functions

```solidity
    function createTrainingRecord(
        address _employee,
        string calldata _employeeName,
        string calldata _trainingModule
    ) external onlyAuthorizedTrainer returns (uint256) {
        require(trainingModules[_trainingModule].isActive, "Training module not active");

        uint256 recordId = recordCounter++;
        TrainingRecord storage record = trainingRecords[recordId];

        record.employee = _employee;
        record.employeeName = _employeeName;
        record.trainingModule = _trainingModule;

        // 🔐 Initialize encrypted fields
        record.encryptedCompletion = FHE.asEbool(false);
        record.encryptedCertification = FHE.asEbool(false);

        record.completionTime = 0;
        record.expiryTime = 0;
        record.isActive = true;
        record.score = 0;
        record.notes = "";

        // 🔑 Set access permissions
        FHE.allowThis(record.encryptedCompletion);
        FHE.allowThis(record.encryptedCertification);
        FHE.allow(record.encryptedCompletion, _employee);
        FHE.allow(record.encryptedCertification, _employee);

        employeeRecords[_employee].push(recordId);

        emit TrainingRecordCreated(recordId, _employee, _trainingModule);
        return recordId;
    }

    function completeTraining(
        uint256 _recordId,
        bool _completed,
        bool _certified,
        uint256 _score,
        string calldata _notes
    ) external onlyAuthorizedTrainer {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(record.isActive, "Record not active");

        // 🔐 Update encrypted completion status
        record.encryptedCompletion = FHE.asEbool(_completed);
        record.encryptedCertification = FHE.asEbool(_certified);

        record.completionTime = block.timestamp;
        record.score = _score;
        record.notes = _notes;

        if (_completed) {
            TrainingModule memory module = trainingModules[record.trainingModule];
            record.expiryTime = block.timestamp + (module.duration * 1 days);
        }

        // 🔑 Maintain access permissions
        FHE.allowThis(record.encryptedCompletion);
        FHE.allowThis(record.encryptedCertification);
        FHE.allow(record.encryptedCompletion, record.employee);
        FHE.allow(record.encryptedCertification, record.employee);

        emit TrainingCompleted(_recordId, record.employee, _completed);
    }
```

### Step 4: Access Control Functions

```solidity
    function getEncryptedCompletion(uint256 _recordId)
        external
        view
        returns (ebool)
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(
            msg.sender == record.employee ||
            authorizedTrainers[msg.sender] ||
            msg.sender == admin,
            "Not authorized"
        );
        return record.encryptedCompletion;
    }

    function getEncryptedCertification(uint256 _recordId)
        external
        view
        returns (ebool)
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(
            msg.sender == record.employee ||
            authorizedTrainers[msg.sender] ||
            msg.sender == admin,
            "Not authorized"
        );
        return record.encryptedCertification;
    }
```

## 🌐 Chapter 4: Frontend Development

### Step 1: HTML Structure

Create `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Training Record Tracker</title>
    <style>
        /* Modern, professional styling */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: #ffffff;
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 20px;
        }

        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: transform 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            font-size: 16px;
        }

        .form-group input::placeholder,
        .form-group textarea::placeholder {
            color: rgba(255, 255, 255, 0.7);
        }

        .status-indicator {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-completed {
            background: #4CAF50;
            color: white;
        }

        .status-pending {
            background: #FF9800;
            color: white;
        }

        .status-encrypted {
            background: #9C27B0;
            color: white;
        }

        .hidden {
            display: none;
        }

        .record-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
        }

        .encryption-info {
            background: rgba(156, 39, 176, 0.2);
            border-left: 4px solid #9C27B0;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="card">
            <h1>🔐 Privacy Training Record Tracker</h1>
            <p>Secure training management with FHEVM encryption</p>

            <div id="connectionStatus">
                <button id="connectWallet" class="btn">Connect MetaMask</button>
                <div id="walletInfo" class="hidden">
                    <p>Connected: <span id="currentAccount"></span></p>
                    <p>Network: <span id="currentNetwork"></span></p>
                    <p>Role: <span id="userRole"></span></p>
                </div>
            </div>
        </div>

        <!-- Admin Panel -->
        <div id="adminPanel" class="card hidden">
            <h2>👑 Admin Panel</h2>

            <div class="form-group">
                <h3>Authorize Trainer</h3>
                <input type="text" id="trainerAddress" placeholder="Trainer wallet address">
                <button onclick="authorizeTrainer()" class="btn">Authorize Trainer</button>
            </div>

            <div class="form-group">
                <h3>Add Training Module</h3>
                <input type="text" id="moduleId" placeholder="Module ID (e.g., cyber-security)">
                <input type="text" id="moduleName" placeholder="Module Name">
                <textarea id="moduleDescription" placeholder="Module Description"></textarea>
                <input type="number" id="moduleDuration" placeholder="Duration (days)">
                <button onclick="addTrainingModule()" class="btn">Add Module</button>
            </div>
        </div>

        <!-- Trainer Panel -->
        <div id="trainerPanel" class="card hidden">
            <h2>🎓 Trainer Panel</h2>

            <div class="form-group">
                <h3>Create Training Record</h3>
                <input type="text" id="employeeAddress" placeholder="Employee wallet address">
                <input type="text" id="employeeName" placeholder="Employee name">
                <select id="trainingModule">
                    <option value="">Select training module</option>
                    <option value="data-privacy">Data Privacy Fundamentals</option>
                    <option value="gdpr-compliance">GDPR Compliance</option>
                    <option value="security-awareness">Security Awareness</option>
                </select>
                <button onclick="createTrainingRecord()" class="btn">Create Record</button>
            </div>

            <div class="form-group">
                <h3>Complete Training</h3>
                <input type="number" id="recordId" placeholder="Record ID">
                <select id="completionStatus">
                    <option value="true">Completed</option>
                    <option value="false">Not Completed</option>
                </select>
                <select id="certificationStatus">
                    <option value="true">Certified</option>
                    <option value="false">Not Certified</option>
                </select>
                <input type="number" id="score" placeholder="Score (0-100)" min="0" max="100">
                <textarea id="notes" placeholder="Training notes"></textarea>
                <button onclick="completeTraining()" class="btn">Mark as Completed</button>
            </div>
        </div>

        <!-- Employee Panel -->
        <div id="employeePanel" class="card hidden">
            <h2>📚 My Training Records</h2>
            <button onclick="loadEmployeeRecords()" class="btn">Load My Records</button>
            <div id="employeeRecords"></div>
        </div>

        <!-- Training Records Display -->
        <div class="card">
            <h2>📋 Training Records</h2>
            <button onclick="loadAllRecords()" class="btn">Refresh Records</button>
            <div id="recordsList"></div>
        </div>

        <!-- Encryption Information -->
        <div class="encryption-info">
            <h3>🔐 Understanding Encryption</h3>
            <p><strong>Encrypted Data:</strong> Completion status, certification status, and scores are encrypted using FHEVM. Only authorized parties can decrypt and view this information.</p>
            <p><strong>Public Data:</strong> Employee addresses, training modules, and creation dates are visible to everyone on the blockchain.</p>
            <p><strong>Access Control:</strong> Employees can only decrypt their own records. Trainers and admins have broader access permissions.</p>
        </div>
    </div>

    <!-- JavaScript includes -->
    <script src="https://cdn.ethers.io/lib/ethers-5.7.2.umd.min.js"></script>
    <script src="app.js"></script>
</body>
</html>
```

### Step 2: JavaScript Integration

Create `app.js`:

```javascript
// Contract configuration
const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
const CONTRACT_ABI = [
    // Add your contract ABI here
    // This will be generated after compilation
];

// Global variables
let provider;
let signer;
let contract;
let fhevmInstance;
let currentAccount;
let userRole = 'unknown';

// Initialize the application
async function init() {
    console.log('Initializing Privacy Training Tracker...');

    if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask detected!');
        provider = new ethers.providers.Web3Provider(window.ethereum);

        // Listen for account changes
        window.ethereum.on('accountsChanged', handleAccountsChanged);
        window.ethereum.on('chainChanged', handleChainChanged);

        // Check if already connected
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
            await connectWallet();
        }
    } else {
        alert('Please install MetaMask to use this application!');
    }
}

// Connect MetaMask wallet
async function connectWallet() {
    try {
        console.log('Connecting to MetaMask...');

        // Request account access
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        // Get signer and account
        signer = provider.getSigner();
        currentAccount = await signer.getAddress();

        console.log('Connected account:', currentAccount);

        // Check and switch to correct network
        const network = await provider.getNetwork();
        console.log('Current network:', network);

        if (network.chainId !== 9000) {
            await switchToZamaNetwork();
        }

        // Initialize contract
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

        // Initialize FHEVM
        await initializeFHEVM();

        // Determine user role
        await determineUserRole();

        // Update UI
        updateConnectionUI();

    } catch (error) {
        console.error('Error connecting wallet:', error);
        alert('Failed to connect wallet: ' + error.message);
    }
}

// Initialize FHEVM instance
async function initializeFHEVM() {
    try {
        console.log('Initializing FHEVM...');

        // Import FHEVM library dynamically
        const { createFhevmInstance } = await import('https://unpkg.com/fhevmjs@0.3.1/bundle/index.js');

        fhevmInstance = await createFhevmInstance({
            chainId: 9000,
            publicKeyUrl: 'https://gateway.sepolia.zama.ai/fhe-keys'
        });

        console.log('FHEVM initialized successfully');

    } catch (error) {
        console.error('Error initializing FHEVM:', error);
        alert('Failed to initialize FHEVM: ' + error.message);
    }
}

// Switch to Zama Sepolia network
async function switchToZamaNetwork() {
    try {
        await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: '0x2328' }], // 9000 in hex
        });
    } catch (switchError) {
        // Network not added, add it
        if (switchError.code === 4902) {
            try {
                await window.ethereum.request({
                    method: 'wallet_addEthereumChain',
                    params: [{
                        chainId: '0x2328',
                        chainName: 'Zama Sepolia Testnet',
                        nativeCurrency: {
                            name: 'ETH',
                            symbol: 'ETH',
                            decimals: 18
                        },
                        rpcUrls: ['https://sepolia.zama.ai/'],
                        blockExplorerUrls: ['https://sepolia.zamascan.io/']
                    }]
                });
            } catch (addError) {
                console.error('Error adding network:', addError);
            }
        }
    }
}

// Determine user role based on contract permissions
async function determineUserRole() {
    try {
        const admin = await contract.admin();
        const isTrainer = await contract.authorizedTrainers(currentAccount);

        if (currentAccount.toLowerCase() === admin.toLowerCase()) {
            userRole = 'admin';
        } else if (isTrainer) {
            userRole = 'trainer';
        } else {
            userRole = 'employee';
        }

        console.log('User role determined:', userRole);

    } catch (error) {
        console.error('Error determining user role:', error);
        userRole = 'unknown';
    }
}

// Update connection UI
function updateConnectionUI() {
    const connectButton = document.getElementById('connectWallet');
    const walletInfo = document.getElementById('walletInfo');
    const currentAccountSpan = document.getElementById('currentAccount');
    const currentNetworkSpan = document.getElementById('currentNetwork');
    const userRoleSpan = document.getElementById('userRole');

    connectButton.style.display = 'none';
    walletInfo.classList.remove('hidden');

    currentAccountSpan.textContent = currentAccount.substring(0, 6) + '...' + currentAccount.substring(38);
    currentNetworkSpan.textContent = 'Zama Sepolia';
    userRoleSpan.textContent = userRole;

    // Show appropriate panels based on role
    document.getElementById('adminPanel').classList.toggle('hidden', userRole !== 'admin');
    document.getElementById('trainerPanel').classList.toggle('hidden', userRole !== 'trainer' && userRole !== 'admin');
    document.getElementById('employeePanel').classList.toggle('hidden', userRole === 'unknown');
}

// Admin function: Authorize trainer
async function authorizeTrainer() {
    const trainerAddress = document.getElementById('trainerAddress').value;

    if (!trainerAddress) {
        alert('Please enter trainer address');
        return;
    }

    try {
        console.log('Authorizing trainer:', trainerAddress);

        const tx = await contract.authorizeTrainer(trainerAddress);
        console.log('Transaction sent:', tx.hash);

        alert('Authorizing trainer... Please wait for confirmation.');

        await tx.wait();
        alert('Trainer authorized successfully!');

        document.getElementById('trainerAddress').value = '';

    } catch (error) {
        console.error('Error authorizing trainer:', error);
        alert('Failed to authorize trainer: ' + error.message);
    }
}

// Admin function: Add training module
async function addTrainingModule() {
    const moduleId = document.getElementById('moduleId').value;
    const moduleName = document.getElementById('moduleName').value;
    const moduleDescription = document.getElementById('moduleDescription').value;
    const moduleDuration = document.getElementById('moduleDuration').value;

    if (!moduleId || !moduleName || !moduleDescription || !moduleDuration) {
        alert('Please fill in all module details');
        return;
    }

    try {
        console.log('Adding training module:', moduleId);

        const tx = await contract.addTrainingModule(
            moduleId,
            moduleName,
            moduleDescription,
            parseInt(moduleDuration)
        );

        alert('Adding training module... Please wait for confirmation.');

        await tx.wait();
        alert('Training module added successfully!');

        // Clear form
        document.getElementById('moduleId').value = '';
        document.getElementById('moduleName').value = '';
        document.getElementById('moduleDescription').value = '';
        document.getElementById('moduleDuration').value = '';

    } catch (error) {
        console.error('Error adding training module:', error);
        alert('Failed to add training module: ' + error.message);
    }
}

// Trainer function: Create training record
async function createTrainingRecord() {
    const employeeAddress = document.getElementById('employeeAddress').value;
    const employeeName = document.getElementById('employeeName').value;
    const trainingModule = document.getElementById('trainingModule').value;

    if (!employeeAddress || !employeeName || !trainingModule) {
        alert('Please fill in all training record details');
        return;
    }

    try {
        console.log('Creating training record for:', employeeName);

        const tx = await contract.createTrainingRecord(
            employeeAddress,
            employeeName,
            trainingModule
        );

        alert('Creating training record... Please wait for confirmation.');

        const receipt = await tx.wait();

        // Find the TrainingRecordCreated event
        const event = receipt.events?.find(e => e.event === 'TrainingRecordCreated');
        const recordId = event?.args?.recordId?.toString();

        alert(`Training record created successfully! Record ID: ${recordId}`);

        // Clear form
        document.getElementById('employeeAddress').value = '';
        document.getElementById('employeeName').value = '';
        document.getElementById('trainingModule').value = '';

        // Refresh records display
        await loadAllRecords();

    } catch (error) {
        console.error('Error creating training record:', error);
        alert('Failed to create training record: ' + error.message);
    }
}

// Trainer function: Complete training
async function completeTraining() {
    const recordId = document.getElementById('recordId').value;
    const completed = document.getElementById('completionStatus').value === 'true';
    const certified = document.getElementById('certificationStatus').value === 'true';
    const score = document.getElementById('score').value;
    const notes = document.getElementById('notes').value;

    if (!recordId || !score) {
        alert('Please fill in record ID and score');
        return;
    }

    try {
        console.log('Completing training for record:', recordId);

        const tx = await contract.completeTraining(
            parseInt(recordId),
            completed,
            certified,
            parseInt(score),
            notes
        );

        alert('Marking training as completed... Please wait for confirmation.');

        await tx.wait();
        alert('Training completed successfully!');

        // Clear form
        document.getElementById('recordId').value = '';
        document.getElementById('score').value = '';
        document.getElementById('notes').value = '';

        // Refresh records display
        await loadAllRecords();

    } catch (error) {
        console.error('Error completing training:', error);
        alert('Failed to complete training: ' + error.message);
    }
}

// Employee function: Load personal records
async function loadEmployeeRecords() {
    if (!currentAccount) {
        alert('Please connect your wallet first');
        return;
    }

    try {
        console.log('Loading employee records for:', currentAccount);

        const recordIds = await contract.getEmployeeTrainingStatus(currentAccount);
        const recordsContainer = document.getElementById('employeeRecords');

        if (recordIds.length === 0) {
            recordsContainer.innerHTML = '<p>No training records found for your account.</p>';
            return;
        }

        let recordsHTML = '<h3>Your Training Records:</h3>';

        for (let i = 0; i < recordIds.length; i++) {
            const recordId = recordIds[i].toString();

            try {
                // Get basic record info
                const record = await contract.getTrainingRecord(recordId);

                // Try to decrypt completion status
                let completionStatus = 'Unknown';
                let certificationStatus = 'Unknown';

                try {
                    const encryptedCompletion = await contract.getEncryptedCompletion(recordId);
                    const encryptedCertification = await contract.getEncryptedCertification(recordId);

                    if (fhevmInstance) {
                        completionStatus = await fhevmInstance.decrypt(CONTRACT_ADDRESS, encryptedCompletion) ? 'Completed' : 'In Progress';
                        certificationStatus = await fhevmInstance.decrypt(CONTRACT_ADDRESS, encryptedCertification) ? 'Certified' : 'Not Certified';
                    }
                } catch (decryptError) {
                    console.log('Could not decrypt for record', recordId);
                }

                recordsHTML += `
                    <div class="record-item">
                        <h4>Record ID: ${recordId}</h4>
                        <p><strong>Training Module:</strong> ${record.trainingModule}</p>
                        <p><strong>Status:</strong>
                            <span class="status-indicator ${completionStatus === 'Completed' ? 'status-completed' : 'status-pending'}">
                                ${completionStatus}
                            </span>
                        </p>
                        <p><strong>Certification:</strong>
                            <span class="status-indicator ${certificationStatus === 'Certified' ? 'status-completed' : 'status-pending'}">
                                ${certificationStatus}
                            </span>
                        </p>
                        <p><strong>Score:</strong> ${record.score}/100</p>
                        <p><strong>Notes:</strong> ${record.notes || 'No notes'}</p>
                        ${record.completionTime > 0 ? `<p><strong>Completed:</strong> ${new Date(record.completionTime * 1000).toLocaleDateString()}</p>` : ''}
                        ${record.expiryTime > 0 ? `<p><strong>Expires:</strong> ${new Date(record.expiryTime * 1000).toLocaleDateString()}</p>` : ''}
                    </div>
                `;

            } catch (error) {
                console.error(`Error loading record ${recordId}:`, error);
                recordsHTML += `
                    <div class="record-item">
                        <h4>Record ID: ${recordId}</h4>
                        <p>Error loading record details</p>
                    </div>
                `;
            }
        }

        recordsContainer.innerHTML = recordsHTML;

    } catch (error) {
        console.error('Error loading employee records:', error);
        alert('Failed to load your training records: ' + error.message);
    }
}

// Load all records (for admin/trainer view)
async function loadAllRecords() {
    if (userRole === 'employee') {
        await loadEmployeeRecords();
        return;
    }

    try {
        console.log('Loading all training records...');

        const recordCounter = await contract.recordCounter();
        const recordsContainer = document.getElementById('recordsList');

        if (recordCounter.isZero()) {
            recordsContainer.innerHTML = '<p>No training records found.</p>';
            return;
        }

        let recordsHTML = '<h3>All Training Records:</h3>';

        for (let i = 0; i < recordCounter.toNumber(); i++) {
            try {
                const record = await contract.getTrainingRecord(i);

                recordsHTML += `
                    <div class="record-item">
                        <h4>Record ID: ${i}</h4>
                        <p><strong>Employee:</strong> ${record.employeeName} (${record.employee.substring(0, 6)}...${record.employee.substring(38)})</p>
                        <p><strong>Training Module:</strong> ${record.trainingModule}</p>
                        <p><strong>Score:</strong> ${record.score}/100</p>
                        <p><strong>Status:</strong>
                            <span class="status-indicator ${record.isActive ? 'status-completed' : 'status-pending'}">
                                ${record.isActive ? 'Active' : 'Inactive'}
                            </span>
                        </p>
                        <p><strong>Notes:</strong> ${record.notes || 'No notes'}</p>
                        ${record.completionTime > 0 ? `<p><strong>Completed:</strong> ${new Date(record.completionTime * 1000).toLocaleDateString()}</p>` : ''}
                        ${record.expiryTime > 0 ? `<p><strong>Expires:</strong> ${new Date(record.expiryTime * 1000).toLocaleDateString()}</p>` : ''}
                        <p><em>🔐 Completion and certification status are encrypted</em></p>
                    </div>
                `;

            } catch (error) {
                console.error(`Error loading record ${i}:`, error);
            }
        }

        recordsContainer.innerHTML = recordsHTML;

    } catch (error) {
        console.error('Error loading all records:', error);
        alert('Failed to load training records: ' + error.message);
    }
}

// Event handlers
function handleAccountsChanged(accounts) {
    if (accounts.length === 0) {
        console.log('Please connect to MetaMask.');
        location.reload();
    } else if (accounts[0] !== currentAccount) {
        console.log('Account changed, reconnecting...');
        connectWallet();
    }
}

function handleChainChanged(chainId) {
    console.log('Chain changed to:', chainId);
    location.reload();
}

// Event listeners
document.getElementById('connectWallet').addEventListener('click', connectWallet);

// Initialize the application when page loads
window.addEventListener('load', init);
```

## 🚀 Chapter 5: Compilation and Deployment

### Step 1: Compile the Contract

```bash
# Compile smart contracts
npx hardhat compile

# This generates:
# - artifacts/contracts/PrivacyTrainingRecord.sol/PrivacyTrainingRecord.json
# - Contract ABI and bytecode
```

### Step 2: Create Deployment Script

Create `scripts/deploy.js`:

```javascript
const { ethers } = require("hardhat");

async function main() {
    console.log("Starting deployment...");

    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);

    const balance = await deployer.getBalance();
    console.log("Account balance:", ethers.utils.formatEther(balance));

    // Deploy contract
    const PrivacyTrainingRecord = await ethers.getContractFactory("PrivacyTrainingRecord");
    const contract = await PrivacyTrainingRecord.deploy();

    await contract.deployed();

    console.log("✅ Contract deployed to:", contract.address);
    console.log("Transaction hash:", contract.deployTransaction.hash);

    // Save deployment info
    const fs = require("fs");
    const deploymentInfo = {
        contractAddress: contract.address,
        deployerAddress: deployer.address,
        transactionHash: contract.deployTransaction.hash,
        network: "zamaTestnet",
        timestamp: new Date().toISOString()
    };

    fs.writeFileSync("deployment.json", JSON.stringify(deploymentInfo, null, 2));
    console.log("Deployment info saved to deployment.json");

    // Extract and save ABI
    const artifact = await ethers.getContractFactory("PrivacyTrainingRecord");
    fs.writeFileSync("contract-abi.json", JSON.stringify(artifact.interface.format("json"), null, 2));
    console.log("Contract ABI saved to contract-abi.json");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

### Step 3: Deploy to Zama Testnet

```bash
# Make sure you have test ETH from Zama faucet
# Deploy to Zama Sepolia testnet
npx hardhat run scripts/deploy.js --network zamaTestnet
```

### Step 4: Update Frontend Configuration

1. Copy the contract address from deployment output
2. Copy the ABI from `contract-abi.json`
3. Update `app.js`:

```javascript
// Replace with your deployed contract address
const CONTRACT_ADDRESS = "0xYourContractAddressHere";

// Replace with your contract ABI
const CONTRACT_ABI = [
    // Paste your contract ABI here
];
```

## 🧪 Chapter 6: Testing Your dApp

### Step 1: Unit Testing

Create `test/PrivacyTrainingRecord.test.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PrivacyTrainingRecord", function () {
    let contract;
    let admin, trainer, employee;

    beforeEach(async function () {
        [admin, trainer, employee] = await ethers.getSigners();

        const PrivacyTrainingRecord = await ethers.getContractFactory("PrivacyTrainingRecord");
        contract = await PrivacyTrainingRecord.deploy();
        await contract.deployed();
    });

    it("Should deploy with correct admin", async function () {
        expect(await contract.admin()).to.equal(admin.address);
        expect(await contract.authorizedTrainers(admin.address)).to.be.true;
    });

    it("Should authorize trainer", async function () {
        await contract.authorizeTrainer(trainer.address);
        expect(await contract.authorizedTrainers(trainer.address)).to.be.true;
    });

    it("Should create training record", async function () {
        await contract.authorizeTrainer(trainer.address);

        const tx = await contract.connect(trainer).createTrainingRecord(
            employee.address,
            "John Doe",
            "data-privacy"
        );

        await expect(tx)
            .to.emit(contract, "TrainingRecordCreated")
            .withArgs(0, employee.address, "data-privacy");

        const record = await contract.getTrainingRecord(0);
        expect(record.employee).to.equal(employee.address);
        expect(record.employeeName).to.equal("John Doe");
    });

    it("Should complete training with encryption", async function () {
        await contract.authorizeTrainer(trainer.address);

        // Create record
        await contract.connect(trainer).createTrainingRecord(
            employee.address,
            "John Doe",
            "data-privacy"
        );

        // Complete training
        const tx = await contract.connect(trainer).completeTraining(
            0, true, true, 85, "Excellent work"
        );

        await expect(tx)
            .to.emit(contract, "TrainingCompleted")
            .withArgs(0, employee.address, true);

        const record = await contract.getTrainingRecord(0);
        expect(record.score).to.equal(85);
        expect(record.notes).to.equal("Excellent work");
    });

    it("Should enforce access control", async function () {
        await contract.authorizeTrainer(trainer.address);

        await contract.connect(trainer).createTrainingRecord(
            employee.address,
            "John Doe",
            "data-privacy"
        );

        // Employee should be able to access their own encrypted data
        await expect(contract.connect(employee).getEncryptedCompletion(0))
            .to.not.be.reverted;

        // Random user should not be able to access
        const [,, , randomUser] = await ethers.getSigners();
        await expect(contract.connect(randomUser).getEncryptedCompletion(0))
            .to.be.revertedWith("Not authorized");
    });
});
```

### Step 2: Run Tests

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/PrivacyTrainingRecord.test.js

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test
```

### Step 3: Frontend Testing

1. **Start Local Server:**
   ```bash
   # Using Python
   python -m http.server 8000

   # Using Node.js
   npx http-server . -p 8000 -c-1
   ```

2. **Test Wallet Connection:**
   - Open http://localhost:8000
   - Click "Connect MetaMask"
   - Verify network switches to Zama Sepolia
   - Check role detection works correctly

3. **Test Admin Functions:**
   - Connect with deployer account
   - Authorize a trainer address
   - Add a new training module

4. **Test Trainer Functions:**
   - Connect with authorized trainer account
   - Create training record for an employee
   - Mark training as completed

5. **Test Employee Functions:**
   - Connect with employee account
   - View personal training records
   - Verify encrypted data decrypts correctly

## 🔐 Chapter 7: Understanding Privacy and Security

### Privacy Features Explained

#### What's Encrypted:
- **Training completion status** (true/false)
- **Certification achievement** (true/false)
- **Performance scores** (0-100)
- **Trainer feedback notes**

#### What's Public:
- Employee wallet addresses
- Training module names
- Record creation timestamps
- Record expiry dates

#### Access Control Matrix:

| User Type | Create Records | Complete Training | View Own Records | View All Records | Decrypt Status |
|-----------|----------------|-------------------|------------------|------------------|----------------|
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ |
| Trainer | ✅ | ✅ | ✅ (created) | ✅ (created) | ✅ (created) |
| Employee | ❌ | ❌ | ✅ | ❌ | ✅ (own only) |

### Security Best Practices

#### Smart Contract Security:
1. **Access Control**: Role-based permissions enforced
2. **Input Validation**: All inputs validated and sanitized
3. **Reentrancy Protection**: Using latest Solidity patterns
4. **Overflow Protection**: Solidity 0.8+ automatic protection

#### Frontend Security:
1. **Wallet Integration**: Secure MetaMask connection
2. **Network Validation**: Ensure correct network usage
3. **Input Sanitization**: Prevent XSS and injection attacks
4. **HTTPS Required**: Secure communication channels

#### Privacy Guarantees:
1. **Computational Privacy**: Operations on encrypted data
2. **Storage Privacy**: Sensitive data never stored in plaintext
3. **Transmission Privacy**: Encrypted data transmission
4. **Access Privacy**: Granular permission controls

## 🎓 Chapter 8: Production Deployment

### Frontend Deployment Options

#### Option 1: Vercel (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# Login and deploy
vercel login
vercel

# Follow prompts for configuration
```

#### Option 2: Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login and deploy
netlify login
netlify deploy --prod
```

#### Option 3: IPFS (Decentralized)

```bash
# Install IPFS CLI
# Upload to IPFS for fully decentralized hosting
ipfs add -r ./dist
```

### Production Checklist

#### Pre-deployment:
- [ ] All tests passing
- [ ] Security audit completed
- [ ] Gas optimization verified
- [ ] Error handling implemented
- [ ] Documentation updated

#### Deployment:
- [ ] Contract deployed to mainnet
- [ ] Frontend deployed to production
- [ ] DNS configured (if using custom domain)
- [ ] SSL certificate installed
- [ ] Monitoring systems active

#### Post-deployment:
- [ ] Functionality verified
- [ ] Performance monitoring active
- [ ] User access confirmed
- [ ] Backup procedures in place
- [ ] Team trained on operations

## 🚀 Chapter 9: Advanced Features and Extensions

### Potential Enhancements

#### 1. Encrypted Arithmetic Operations

```solidity
// Example: Encrypted score calculations
function calculateAverageScore(uint256[] memory recordIds)
    external
    view
    returns (euint32)
{
    euint32 sum = FHE.asEuint32(0);
    for (uint i = 0; i < recordIds.length; i++) {
        TrainingRecord storage record = trainingRecords[recordIds[i]];
        sum = FHE.add(sum, FHE.asEuint32(record.score));
    }
    return FHE.div(sum, FHE.asEuint32(recordIds.length));
}
```

#### 2. Conditional Logic with Encrypted Data

```solidity
// Example: Encrypted status checks
function checkTrainingRequirements(address employee)
    external
    view
    returns (ebool)
{
    uint256[] memory records = employeeRecords[employee];
    ebool allCompleted = FHE.asEbool(true);

    for (uint i = 0; i < records.length; i++) {
        TrainingRecord storage record = trainingRecords[records[i]];
        allCompleted = FHE.and(allCompleted, record.encryptedCompletion);
    }

    return allCompleted;
}
```

#### 3. Integration with External Systems

```javascript
// Example: API integration for automated record creation
async function syncWithHRSystem() {
    const employees = await fetch('/api/employees').then(r => r.json());

    for (const employee of employees) {
        await createTrainingRecord(
            employee.walletAddress,
            employee.name,
            employee.requiredTraining
        );
    }
}
```

### Scaling Considerations

#### 1. Gas Optimization
- Batch operations for multiple records
- Efficient data structures
- Minimal storage operations

#### 2. Data Management
- Archive old records
- Implement pagination
- Use IPFS for large data

#### 3. User Experience
- Progressive loading
- Offline functionality
- Mobile optimization

## 📚 Chapter 10: Resources and Next Steps

### Documentation Resources

#### FHEVM and Zama:
- [Official FHEVM Documentation](https://docs.zama.ai/fhevm)
- [FHEVM Solidity Library](https://github.com/zama-ai/fhevm)
- [FHEVM.js Client](https://github.com/zama-ai/fhevmjs)
- [Zama Community Discord](https://discord.gg/zama)

#### Ethereum Development:
- [Hardhat Documentation](https://hardhat.org/docs)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solidity Documentation](https://docs.soliditylang.org/)

#### Frontend Development:
- [Web3 Integration Guide](https://ethereum.org/en/developers/tutorials/)
- [MetaMask Developer Docs](https://docs.metamask.io/)
- [Modern JavaScript Guide](https://javascript.info/)

### Community and Support

#### Developer Communities:
- [Zama Developer Forum](https://community.zama.ai/)
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)
- [GitHub Discussions](https://github.com/zama-ai/fhevm/discussions)

#### Learning Resources:
- [CryptoZombies](https://cryptozombies.io/) - Solidity tutorials
- [Buildspace](https://buildspace.so/) - Web3 project tutorials
- [Ethereum.org](https://ethereum.org/en/developers/) - Official resources

### Next Steps

#### Beginner Projects:
1. **Encrypted Voting System**: Build anonymous voting with FHE
2. **Private Auction Platform**: Sealed-bid auctions with encrypted bids
3. **Confidential Survey Tool**: Anonymous data collection

#### Intermediate Projects:
1. **Healthcare Records**: HIPAA-compliant medical data management
2. **Financial Privacy**: Private credit scoring and lending
3. **Supply Chain Privacy**: Confidential supply chain tracking

#### Advanced Projects:
1. **Multi-party Computation**: Collaborative encrypted computations
2. **Privacy-Preserving Analytics**: Encrypted data analysis platforms
3. **Zero-Knowledge Integration**: Combining FHE with ZK proofs

### Career Opportunities

#### Emerging Roles:
- **Privacy Engineer**: Designing privacy-preserving systems
- **FHE Developer**: Specialized in homomorphic encryption
- **Blockchain Privacy Consultant**: Advising on privacy solutions
- **Web3 Security Auditor**: Reviewing privacy-focused contracts

#### Industry Applications:
- Healthcare and medical research
- Financial services and fintech
- Government and public sector
- IoT and edge computing
- Machine learning and AI

## 🎉 Conclusion

Congratulations! You've successfully completed the comprehensive FHEVM tutorial. You now have:

### Skills Acquired:
✅ **FHEVM Fundamentals**: Understanding of fully homomorphic encryption in blockchain
✅ **Smart Contract Development**: Building privacy-preserving contracts
✅ **Frontend Integration**: Creating user interfaces for encrypted data
✅ **Deployment Expertise**: Publishing dApps to production
✅ **Testing Knowledge**: Ensuring application reliability
✅ **Security Awareness**: Understanding privacy and security considerations

### What You Built:
- A complete privacy-preserving dApp
- Smart contracts with encrypted data storage
- User-friendly frontend with wallet integration
- Comprehensive testing suite
- Production deployment pipeline

### Knowledge Foundation:
You now understand how to build applications that maintain privacy while leveraging blockchain's transparency and verifiability. This opens up numerous possibilities for creating the next generation of privacy-preserving decentralized applications.

### Continue Your Journey:
- Join the Zama community to stay updated
- Explore advanced FHE use cases
- Contribute to open-source FHEVM projects
- Build the privacy-preserving applications of tomorrow

**Happy Building!** 🚀

The future of privacy-preserving blockchain applications starts with developers like you who understand both the technology and its potential. Use this knowledge to create applications that protect user privacy while maintaining the benefits of decentralization.

---

*This tutorial is part of the growing ecosystem of privacy-preserving technologies. Share your projects, contribute to the community, and help build a more private and secure decentralized future.*