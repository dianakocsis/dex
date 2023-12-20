# DEX

## Description

An app that allows users to seamlessly trade ERC20 BALLOONS ($BAL) with ETH in a decentralized manner. Users will be able to connect their wallets, view their token balances, and buy or sell their tokens according to a price formula.

## Installation and Setup Instructions

### Prerequisites

- Node (v18 LTS)
- Yarn (v1 or v2+)
- Git

### Clone the Repository

To get started, clone the repository to your local machine:

```bash
git clone https://github.com/dianakocsis/dex
```

### Environment Setup

1. Navigate to the cloned directory:

   ```bash
   cd dex
   ```

2. Copy the .env.example files to create a new .env file and fill in the necessary details:

   ```bash
   cp .env.example .env
   ```

   ```bash
   cd frontend
   cp .env.example .env
   ```

### Environment Setup

1. Install Dependencies

   To install project dependencies, run the following commands:

   ```bash
   yarn install
   cd frontend && yarn install
   cd ..
   ```

2. Start Local Blockchain

   In a new terminal, start the local blockchain:

   ```bash
   yarn chain
   ```

3. Deploy Contracts (In another tab)

   Open another terminal tab and deploy the contracts:

   ```bash
   yarn deploy
   ```

4. Start the Aplication (In another tab)

   Finally, in a new terminal tab, start the application:

   ```bash
   yarn start
   ```

## Testnet Deploy Information

| Contract | Address Etherscan Link                                                            |
| -------- | --------------------------------------------------------------------------------- |
| Balloons | `https://sepolia.etherscan.io/address/0x0c2Eb7214bC28A434400913942475c13F5358b94` |
| DEX      | `https://sepolia.etherscan.io/address/0xAbA22F27684a1AA6D47b53Fff793158ecF018f8B` |
