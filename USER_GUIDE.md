# User Guide: Privacy Training Record Tracker

Complete guide for using the Privacy Training Record Tracker dApp - a beginner-friendly FHEVM application for managing confidential training records.

## Table of Contents

- [Getting Started](#getting-started)
- [Wallet Setup](#wallet-setup)
- [User Roles](#user-roles)
- [Admin Functions](#admin-functions)
- [Trainer Functions](#trainer-functions)
- [Employee Functions](#employee-functions)
- [Understanding Encryption](#understanding-encryption)
- [Troubleshooting](#troubleshooting)

## Getting Started

### What is This Application?

The Privacy Training Record Tracker is a decentralized application (dApp) that manages employee training records while keeping sensitive completion data encrypted on the blockchain. Unlike traditional systems, completion status remains private and can only be viewed by authorized parties.

### Key Benefits

- **Privacy-First:** Training completion status encrypted using FHEVM
- **Transparent:** All interactions recorded on blockchain
- **Decentralized:** No single point of failure
- **Verifiable:** Cryptographic proof of training completion
- **Compliant:** Meets privacy regulations like GDPR

## Wallet Setup

### 1. Install MetaMask

1. Visit [MetaMask.io](https://metamask.io/)
2. Download and install the browser extension
3. Create a new wallet or import existing one
4. **Important:** Securely store your seed phrase

### 2. Add Zama Sepolia Testnet

Add this network to MetaMask:

- **Network Name:** Zama Sepolia Testnet
- **RPC URL:** https://sepolia.zama.ai/
- **Chain ID:** 9000
- **Currency Symbol:** ETH
- **Block Explorer:** https://sepolia.zamascan.io/

### 3. Get Test ETH

1. Visit [Zama Faucet](https://faucet.zama.ai/)
2. Connect your MetaMask wallet
3. Request test ETH (needed for transactions)
4. Wait for confirmation

## User Roles

The application supports three distinct user roles:

### Administrator
- Creates and manages training modules
- Authorizes trainers
- Oversees system administration
- Views all training records

### Trainer
- Creates training records for employees
- Marks training as completed
- Enters performance scores and notes
- Views records they've created

### Employee
- Views their own training records
- Accesses encrypted completion status
- Tracks training progress and expiry dates
- Downloads completion certificates

## Admin Functions

### Accessing Admin Panel

1. Connect your wallet to the dApp
2. If you're the contract deployer, you automatically have admin rights
3. Admin panel appears with additional management options

### Authorize New Trainers

```javascript
// Example: Authorizing a trainer
1. Navigate to "Trainer Management"
2. Enter trainer's wallet address
3. Click "Authorize Trainer"
4. Confirm transaction in MetaMask
```

**Steps:**
1. Click "Manage Trainers" in admin panel
2. Enter the trainer's Ethereum address
3. Click "Authorize Trainer"
4. Confirm the transaction in MetaMask
5. Wait for blockchain confirmation

### Revoke Trainer Access

1. Go to "Active Trainers" list
2. Find the trainer to revoke
3. Click "Revoke Access"
4. Confirm transaction

### Add Training Modules

1. Navigate to "Module Management"
2. Fill in module details:
   - **Module ID:** Unique identifier (e.g., "cyber-security-2024")
   - **Name:** Display name (e.g., "Cybersecurity Awareness 2024")
   - **Description:** Detailed description
   - **Duration:** Validity period in days
3. Click "Add Module"
4. Confirm transaction

### View System Statistics

The admin dashboard shows:
- Total training records created
- Number of active trainers
- Module completion rates
- Recent activity log

## Trainer Functions

### Connect as Trainer

1. Ensure your wallet is authorized by an admin
2. Connect to the dApp
3. Trainer interface appears automatically

### Create Training Record

**Step-by-step process:**

1. **Access Creation Form:**
   - Click "Create New Training Record"
   - Form appears with required fields

2. **Fill Employee Information:**
   ```
   Employee Address: 0x742d35Cc6633Bb532f85D7f89e2C45F18F5a5C52
   Employee Name: John Smith
   Training Module: Select from dropdown (e.g., "Data Privacy Fundamentals")
   ```

3. **Submit Record:**
   - Click "Create Record"
   - MetaMask prompts for transaction approval
   - Confirm transaction (gas fee required)
   - Wait for blockchain confirmation

4. **Verify Creation:**
   - Record appears in "My Created Records"
   - Employee receives notification (if email integration enabled)
   - Record ID generated for tracking

### Complete Training

**Mark training as completed:**

1. **Find the Record:**
   - Go to "Active Training Records"
   - Search by employee name or record ID
   - Click on the record to open

2. **Enter Completion Details:**
   ```
   Completion Status: ✓ Completed
   Certification Earned: ✓ Yes
   Score: 85 (out of 100)
   Notes: "Excellent understanding of privacy principles.
          Completed all modules ahead of schedule."
   ```

3. **Encrypt and Submit:**
   - The completion status automatically encrypts using FHEVM
   - Click "Mark as Completed"
   - Confirm transaction in MetaMask
   - Completion data is now encrypted on-chain

### View Training Records

**Access your created records:**

1. Navigate to "My Records" tab
2. View list of all records you've created
3. Filter by:
   - Completion status
   - Training module
   - Date range
   - Employee name

4. Click any record for detailed view

## Employee Functions

### View Personal Training Records

**Access your training information:**

1. **Connect Wallet:**
   - Connect your personal MetaMask wallet
   - Ensure you're on Zama Sepolia testnet

2. **Access Training Dashboard:**
   - Employee interface loads automatically
   - Shows your personal training overview

3. **View Record Details:**
   - See assigned training modules
   - Check completion status (decrypted for you)
   - View expiry dates and renewal requirements

### Decrypt Completion Status

**Understanding encrypted data:**

1. **Automatic Decryption:**
   - When you view your records, completion status decrypts automatically
   - Only you can see your actual completion status
   - Others see encrypted data that cannot be read

2. **Verification Process:**
   ```javascript
   // What happens behind the scenes:
   - Your wallet signature proves identity
   - FHEVM client decrypts data using your private key
   - Completion status displays as "Completed" or "In Progress"
   ```

### Download Certificates

1. Navigate to completed training records
2. Click "Download Certificate" for completed trainings
3. PDF certificate generates with:
   - Your name and wallet address
   - Training module completed
   - Completion date
   - Certification status
   - Blockchain verification hash

### Track Training Progress

**Monitor your learning journey:**

1. **Dashboard Overview:**
   - Total trainings assigned: 5
   - Completed: 3
   - In progress: 1
   - Expired/Need renewal: 1

2. **Progress Tracking:**
   - Visual progress bars for each module
   - Upcoming expiry dates highlighted
   - Renewal notifications

## Understanding Encryption

### What Data is Encrypted?

**Encrypted (Private):**
- Training completion status (true/false)
- Certification achievement (true/false)
- Performance scores
- Trainer notes and feedback

**Public (Visible to All):**
- Employee wallet address
- Training module assigned
- Record creation date
- Training expiry date

### How Encryption Works

1. **Creation:** When a trainer marks training complete, the status encrypts using FHEVM
2. **Storage:** Encrypted data stores on blockchain - unreadable to outsiders
3. **Access:** Only authorized parties can decrypt and view the data
4. **Verification:** Blockchain proves data integrity without revealing content

### Access Control

**Who can see what:**

| Data Type | Admin | Trainer | Employee | Public |
|-----------|-------|---------|----------|--------|
| Completion Status | ✓ | ✓ | ✓ (own) | ✗ |
| Certification | ✓ | ✓ | ✓ (own) | ✗ |
| Scores | ✓ | ✓ | ✓ (own) | ✗ |
| Trainer Notes | ✓ | ✓ | ✓ (own) | ✗ |
| Employee Address | ✓ | ✓ | ✓ | ✓ |
| Module Name | ✓ | ✓ | ✓ | ✓ |
| Creation Date | ✓ | ✓ | ✓ | ✓ |

## Troubleshooting

### Common Issues and Solutions

#### 1. "MetaMask Not Connected"

**Problem:** Wallet not connecting to dApp
**Solutions:**
- Refresh the page and try again
- Check if MetaMask is unlocked
- Verify you're on the correct network (Zama Sepolia)
- Clear browser cache and cookies

#### 2. "Wrong Network"

**Problem:** Connected to wrong blockchain network
**Solutions:**
- Click the network switcher in the dApp
- Manually switch in MetaMask to Zama Sepolia
- Add the network if not already configured

#### 3. "Insufficient Funds"

**Problem:** Not enough ETH for transactions
**Solutions:**
- Visit [Zama Faucet](https://faucet.zama.ai/) for test ETH
- Wait for faucet cooldown period (usually 24 hours)
- Ask admin for test tokens

#### 4. "Transaction Failed"

**Problem:** Blockchain transaction rejected
**Solutions:**
- Check gas fee settings (try higher gas price)
- Ensure sufficient ETH balance
- Wait for network congestion to clear
- Try transaction again

#### 5. "Access Denied"

**Problem:** Can't access certain functions
**Solutions:**
- Verify your role permissions
- Contact admin to authorize your account
- Ensure you're using correct wallet address

#### 6. "Data Not Loading"

**Problem:** Training records not displaying
**Solutions:**
- Wait for blockchain synchronization
- Refresh the page
- Check browser console for errors
- Verify contract address is correct

#### 7. "Decryption Failed"

**Problem:** Cannot view encrypted completion status
**Solutions:**
- Ensure you have permission to view the data
- Check if you're the record owner
- Verify FHEVM client initialization
- Try disconnecting and reconnecting wallet

### Getting Help

#### Documentation Resources
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [MetaMask Support](https://support.metamask.io/)
- [Ethereum Basics](https://ethereum.org/en/learn/)

#### Community Support
- [Zama Discord](https://discord.gg/zama)
- [GitHub Issues](https://github.com/your-repo/issues)
- [Developer Forums](https://community.zama.ai/)

#### Contact Information
- **Technical Support:** support@your-domain.com
- **Admin Contact:** admin@your-domain.com
- **Emergency Contact:** emergency@your-domain.com

### Best Practices

#### Security
- Never share your private key or seed phrase
- Always verify contract addresses before transactions
- Use official links and avoid phishing sites
- Keep MetaMask and browser updated

#### Usage
- Regular backup of important data
- Monitor training expiry dates
- Complete trainings before deadlines
- Keep transaction records for auditing

#### Privacy
- Understand what data is encrypted vs. public
- Only share wallet addresses when necessary
- Be aware of blockchain transaction history
- Use privacy-focused browsers when possible

## Advanced Features

### Batch Operations

**For admins and trainers managing multiple records:**

1. **Bulk Record Creation:**
   - Upload CSV file with employee data
   - Automatically create multiple training records
   - Verify all creations in batch summary

2. **Mass Completion:**
   - Select multiple records
   - Mark all as completed simultaneously
   - Apply same score/notes to all

### API Integration

**For organizations with existing systems:**

1. **Employee Management Systems:**
   - Connect HR systems to auto-create records
   - Sync employee data automatically
   - Update training status in real-time

2. **Learning Management Systems:**
   - Import training completion from LMS
   - Automatically mark blockchain records
   - Generate compliance reports

### Reporting and Analytics

1. **Compliance Reports:**
   - Generate privacy-compliant reports
   - Export completion statistics
   - Audit trail documentation

2. **Performance Analytics:**
   - Training effectiveness metrics
   - Completion rate analysis
   - Employee progress tracking

---

This user guide provides comprehensive instructions for all user types. For additional support, refer to the troubleshooting section or contact our support team.