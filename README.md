Secure Health Record Platform Using Blockchain

A decentralized application (DApp) for secure health data management, allowing patients and doctors to register, manage, and share health records using blockchain and IPFS.

## Features

- Blockchain-based health record storage
- Patient and doctor registration
- Record creation and retrieval
- IPFS integration for decentralized file storage
- Built with Solidity, Truffle, Ganache, React, TypeScript

## Tech Stack

- **Smart Contracts**: Solidity
- **Development Framework**: Truffle
- **Local Blockchain**: Ganache
- **Frontend**: React + TypeScript
- **Decentralized Storage**: IPFS (via Pinata/NFT.Storage)
- **Wallet Integration**: MetaMask

## Installation & Setup

### Prerequisites

Make sure you have the following installed:

- [Node.js](https://nodejs.org/) (v14 or later)
- [Truffle](https://trufflesuite.com/)  
  ```bash
  npm install -g truffle
````

* [Ganache](https://trufflesuite.com/ganache/) (GUI or CLI)
* [MetaMask](https://metamask.io/) extension in your browser
* [IPFS upload service] for the project i used ([Pinata](https://pinata.cloud/)

## Backend (Smart Contracts)

1. **Clone the repo:**

   ```bash
   git clone https://github.com/profvic/Secure-health-platform.git
   cd Blockchain
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Start Ganache**
   Launch Ganache and ensure it’s running on `http://127.0.0.1:7545`.

4. **Compile the smart contracts:**

   ```bash
   truffle compile
   ```

5. **Migrate the contracts:**

   ```bash
   truffle migrate --reset
   ```

6. **(Optional) Run tests:**

   ```bash
   truffle test
   ```

---

## 💻 Frontend (React + TypeScript)

1. **Navigate to the frontend folder (if applicable):**

   ```bash
   cd record-ledger nexus
   ```

2. **Install frontend dependencies:**

   ```bash
   npm install
   ```

3. **Start the frontend server:**

   ```bash
   npm run dev
   ```

4. **Open your browser** and go to:

   ```
   http://localhost:8080
   ```

## 📁 File Upload via IPFS

* Uses [Pinata](https://pinata.cloud/) or [NFT.Storage](https://nft.storage/)

  ```
  VITE_IPFS_API_KEY=your-api-key
  ```

## 🔐 Security & Access

* Users must connect with MetaMask to authenticate.
* Only registered doctors that are given access can view and update patient records.
* Files are stored off-chain via IPFS but referenced on-chain for integrity.



MIT © 2025 Your Name / Team Name

