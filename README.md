# Eco POC Contracts

This repository contains the smart contracts for the Eco POC project, now using Foundry as the development framework.

## Development

This project uses [Foundry](https://book.getfoundry.sh/) for development and testing.

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Setup

Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd eco-poc
forge install
```

### Compile

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

Create a `.env` file with your private key:

```
PRIVATE_KEY=your_private_key_here
```

Then run:

```bash
source .env
forge script script/Deploy.s.sol --rpc-url <your_rpc_url> --broadcast
```

## Contract Overview

### CrowdLiquidityRegistrar

The `CrowdLiquidityRegistrar` contract manages crowd liquidity addresses with admin management capabilities.

Key features:
- Add, remove, and reinstate crowd liquidity addresses
- Lock/unlock functionality
- Role-based access control

### EcoChainCrowdLiquidityCheckModule

The `EcoChainCrowdLiquidityCheckModule` checks whether a caller is allowed based on calldata.

Key features:
- Verifies if calldata to an address is a crowd liquidity address
- Admin permission management

## License

UNLICENSED
