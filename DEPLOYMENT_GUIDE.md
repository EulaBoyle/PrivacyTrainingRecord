# Deployment Guide: Privacy Training Record Tracker

This guide provides step-by-step instructions for deploying your FHEVM Privacy Training Record Tracker from development to production.

## Prerequisites

Before deploying, ensure you have:

- Node.js (v16 or later) installed
- Git installed
- MetaMask wallet with test ETH
- Basic understanding of smart contract deployment

## Development Environment Setup

### 1. Install Required Tools

```bash
# Install Node.js (if not already installed)
# Download from https://nodejs.org/

# Verify installation
node --version
npm --version
```

### 2. Clone the Repository

```bash
git clone [your-repository-url]
cd privacy-training-tracker
```

### 3. Install Dependencies

```bash
# Install project dependencies
npm install

# Install Hardhat development framework
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Install FHEVM libraries
npm install @fhevm/solidity fhevmjs
```

### 4. Environment Configuration

Create a `.env` file in the project root:

```bash
# Wallet private key (without 0x prefix)
PRIVATE_KEY=your_wallet_private_key_here

# Infura project ID for Ethereum node access
INFURA_KEY=your_infura_project_id_here

# Optional: Etherscan API key for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

**Security Note:** Never commit your `.env` file to version control.

## Network Configuration

### Configure MetaMask for Zama Sepolia Testnet

Add the following network to MetaMask:

- **Network Name:** Zama Sepolia Testnet
- **RPC URL:** https://sepolia.zama.ai/
- **Chain ID:** 9000
- **Currency Symbol:** ETH
- **Block Explorer:** https://sepolia.zamascan.io/

### Get Test Tokens

1. Visit the Zama faucet: https://faucet.zama.ai/
2. Connect your MetaMask wallet
3. Request test ETH for deployment and testing

## Smart Contract Deployment

### 1. Create Hardhat Configuration

Create or update `hardhat.config.js`:

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
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 11155111
    },
    zamaTestnet: {
      url: "https://sepolia.zama.ai/",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 9000
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
```

### 2. Create Deployment Script

Create `scripts/deploy.js`:

```javascript
const { ethers } = require("hardhat");

async function main() {
  console.log("Starting deployment...");

  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Check account balance
  const balance = await deployer.getBalance();
  console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

  // Deploy the contract
  const PrivacyTrainingRecord = await ethers.getContractFactory("PrivacyTrainingRecord");

  console.log("Deploying PrivacyTrainingRecord contract...");
  const contract = await PrivacyTrainingRecord.deploy();

  await contract.deployed();

  console.log("✅ Contract deployed successfully!");
  console.log("Contract address:", contract.address);
  console.log("Transaction hash:", contract.deployTransaction.hash);

  // Save deployment information
  const deploymentInfo = {
    contractAddress: contract.address,
    deployerAddress: deployer.address,
    transactionHash: contract.deployTransaction.hash,
    network: "zamaTestnet",
    timestamp: new Date().toISOString()
  };

  const fs = require("fs");
  fs.writeFileSync("deployment.json", JSON.stringify(deploymentInfo, null, 2));
  console.log("Deployment info saved to deployment.json");

  // Verify initial state
  console.log("\nVerifying contract deployment...");
  const admin = await contract.admin();
  console.log("Contract admin:", admin);

  const isAuthorized = await contract.authorizedTrainers(deployer.address);
  console.log("Deployer is authorized trainer:", isAuthorized);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
```

### 3. Deploy to Zama Testnet

```bash
# Compile the contract
npx hardhat compile

# Deploy to Zama Sepolia testnet
npx hardhat run scripts/deploy.js --network zamaTestnet
```

### 4. Verify Deployment

After deployment, you should see output similar to:

```
✅ Contract deployed successfully!
Contract address: 0x1234567890123456789012345678901234567890
Transaction hash: 0xabcdef...
Contract admin: 0xYourWalletAddress
Deployer is authorized trainer: true
```

## Frontend Deployment

### 1. Update Contract Configuration

Update the contract address in your frontend files:

```javascript
// In your frontend JavaScript files
const CONTRACT_ADDRESS = "0x1234567890123456789012345678901234567890"; // Your deployed contract address
const CONTRACT_ABI = [...]; // Your contract ABI
```

### 2. Local Development Server

```bash
# Start local development server
npm run dev

# Or using Python's built-in server
python -m http.server 8000

# Or using Node.js http-server
npx http-server . -p 8000 -c-1
```

### 3. Deploy to Vercel (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Follow the prompts to configure your deployment
```

### 4. Deploy to Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy
netlify deploy

# For production deployment
netlify deploy --prod
```

### 5. Deploy to GitHub Pages

1. Create a `gh-pages` branch:
```bash
git checkout -b gh-pages
git push origin gh-pages
```

2. In your repository settings, enable GitHub Pages from the `gh-pages` branch.

## Production Considerations

### Security Checklist

- [ ] Remove all hardcoded private keys
- [ ] Use environment variables for sensitive data
- [ ] Enable HTTPS for frontend deployment
- [ ] Implement proper error handling
- [ ] Add input validation and sanitization
- [ ] Set up monitoring and logging

### Performance Optimization

- [ ] Optimize smart contract gas usage
- [ ] Implement efficient data structures
- [ ] Use CDN for static assets
- [ ] Enable compression (gzip)
- [ ] Implement caching strategies

### Monitoring and Maintenance

1. **Contract Monitoring:**
   - Monitor contract events and transactions
   - Set up alerts for unusual activity
   - Track gas usage and optimization opportunities

2. **Frontend Monitoring:**
   - Implement analytics (Google Analytics, etc.)
   - Monitor error rates and performance
   - Set up uptime monitoring

3. **Regular Updates:**
   - Keep dependencies updated
   - Monitor security advisories
   - Perform regular backups

## Troubleshooting

### Common Deployment Issues

#### 1. "Insufficient funds for gas"
**Solution:** Ensure your wallet has enough test ETH for deployment.

```bash
# Check balance
npx hardhat run scripts/check-balance.js --network zamaTestnet
```

#### 2. "Network connection failed"
**Solution:** Verify your RPC URL and network configuration.

#### 3. "Contract verification failed"
**Solution:** Ensure your Solidity version matches the compiled contract.

#### 4. "Transaction underpriced"
**Solution:** Increase gas price in your deployment script:

```javascript
const contract = await PrivacyTrainingRecord.deploy({
  gasPrice: ethers.utils.parseUnits("20", "gwei")
});
```

### Frontend Issues

#### 1. "MetaMask not detected"
**Solution:** Ensure MetaMask is installed and enabled.

#### 2. "Wrong network"
**Solution:** Prompt users to switch to the correct network:

```javascript
async function switchNetwork() {
  try {
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: '0x2328' }], // 9000 in hex
    });
  } catch (error) {
    // Handle error
  }
}
```

#### 3. "Contract interaction failed"
**Solution:** Check contract address and ABI configuration.

## Testing Deployment

### 1. Smart Contract Testing

```bash
# Run contract tests
npx hardhat test

# Test on local network
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

### 2. Frontend Testing

1. **Connect Wallet:**
   - Verify MetaMask connection works
   - Check network switching functionality

2. **Contract Interaction:**
   - Test creating training records
   - Verify completing training works
   - Check encrypted data handling

3. **User Interface:**
   - Test all user flows
   - Verify responsive design
   - Check error handling

### 3. End-to-End Testing

Create comprehensive test scenarios:

```javascript
// Example test script
describe("Full dApp Integration", function() {
  it("Should complete full training workflow", async function() {
    // Deploy contract
    // Create training record
    // Complete training
    // Verify encryption
    // Check access control
  });
});
```

## Deployment Checklist

### Pre-Deployment
- [ ] Code review completed
- [ ] All tests passing
- [ ] Security audit performed
- [ ] Environment variables configured
- [ ] Network configuration verified

### Deployment
- [ ] Smart contract deployed successfully
- [ ] Contract address recorded
- [ ] Frontend deployed and accessible
- [ ] DNS configured (if using custom domain)
- [ ] SSL certificate installed

### Post-Deployment
- [ ] Deployment verification completed
- [ ] Monitoring systems activated
- [ ] Documentation updated
- [ ] Team notified of deployment
- [ ] Backup procedures in place

## Support and Resources

### Documentation
- [Hardhat Documentation](https://hardhat.org/docs)
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [MetaMask Developer Docs](https://docs.metamask.io/)

### Community Support
- [Zama Discord](https://discord.gg/zama)
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)
- [Hardhat Discord](https://discord.gg/hardhat)

### Professional Services
- Smart contract auditing services
- DevOps consulting for blockchain projects
- Security assessment services

---

This deployment guide provides a comprehensive pathway from development to production. Follow each step carefully and refer to the troubleshooting section for common issues.