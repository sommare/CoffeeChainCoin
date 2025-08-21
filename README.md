# CoffeeChainCoin (CCC)

A Clarity-based smart contract for managing token reward distribution in daily coffee purchase rewards programs on the Stacks blockchain.

## Overview

CoffeeChainCoin is a SIP-010 compliant fungible token smart contract that enables coffee shops to distribute reward tokens to customers for their daily coffee purchases. The contract implements a fair reward system with daily limits and automated tracking to prevent abuse while encouraging customer loyalty.

## Features

- **SIP-010 Compliant**: Fully implements the Stacks Improvement Proposal 010 fungible token standard
- **Daily Reward System**: Customers can earn 1 CCC token per coffee purchase (up to 3 per day)
- **Coffee Shop Registration**: Only registered coffee shops can distribute rewards
- **Anti-Abuse Protection**: Daily claim limits and block-based time tracking prevent exploitation
- **Owner Controls**: Contract owner can manage coffee shop registrations and reward pool
- **Transparent Tracking**: All reward distributions and balances are publicly verifiable

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity v2
- **Token Standard**: SIP-010 Fungible Token
- **Token Symbol**: CCC
- **Decimals**: 6
- **Daily Reward**: 1.000000 CCC (1,000,000 micro-tokens)
- **Max Daily Claims**: 3 per customer
- **Time Calculation**: ~144 blocks per day (10-minute block times)

## Project Structure

```
CoffeeChainCoin/
├── README.md
├── .gitignore
└── CoffeeChainCoin_contract/
    ├── Clarinet.toml              # Project configuration
    ├── package.json               # Dependencies and scripts
    ├── tsconfig.json             # TypeScript configuration
    ├── vitest.config.js          # Test configuration
    ├── contracts/
    │   └── CoffeeChainCoin.clar  # Main smart contract
    ├── tests/
    │   └── CoffeeChainCoin.test.ts # Test suite
    └── settings/
        ├── Devnet.toml           # Development network settings
        ├── Testnet.toml          # Testnet settings
        └── Mainnet.toml          # Mainnet settings
```

## Installation

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) - Clarity development tool
- [Node.js](https://nodejs.org/) v16+ - For running tests
- [Git](https://git-scm.com/) - Version control

### Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd CoffeeChainCoin
   ```

2. **Install dependencies**:
   ```bash
   cd CoffeeChainCoin_contract
   npm install
   ```

3. **Verify installation**:
   ```bash
   clarinet check
   ```

## Usage Examples

### Basic Contract Interaction

#### Initialize the Contract
```clarity
;; Initialize with 1,000,000 CCC tokens (1,000,000,000,000 micro-tokens)
(contract-call? .CoffeeChainCoin initialize u1000000000000)
```

#### Register a Coffee Shop
```clarity
;; Register a coffee shop (owner only)
(contract-call? .CoffeeChainCoin register-coffee-shop 'SP1ABC123DEF456GHI789JKL)
```

#### Distribute Rewards
```clarity
;; Coffee shop distributes reward to customer
(contract-call? .CoffeeChainCoin distribute-reward 'SP1CUSTOMER123ADDRESS)
```

#### Check Balances
```clarity
;; Get customer token balance
(contract-call? .CoffeeChainCoin get-balance 'SP1CUSTOMER123ADDRESS)

;; Check remaining daily claims
(contract-call? .CoffeeChainCoin get-remaining-daily-claims 'SP1CUSTOMER123ADDRESS)
```

### Testing

Run the test suite:
```bash
npm test                    # Run tests once
npm run test:report        # Run with coverage and cost analysis
npm run test:watch         # Watch mode for development
```

## Contract Functions

### Public Functions

#### Owner Functions
- `initialize(initial-pool: uint)` - Initialize contract with reward pool
- `register-coffee-shop(shop: principal)` - Register a coffee shop
- `unregister-coffee-shop(shop: principal)` - Remove coffee shop registration
- `mint(amount: uint, recipient: principal)` - Mint new tokens
- `add-to-rewards-pool(amount: uint)` - Add tokens to reward pool

#### Coffee Shop Functions
- `distribute-reward(customer: principal)` - Distribute daily reward to customer

#### User Functions
- `transfer(amount: uint, sender: principal, recipient: principal, memo: optional<buff>)` - Transfer tokens

### Read-Only Functions

#### Token Information
- `get-name()` - Returns "CoffeeChainCoin"
- `get-symbol()` - Returns "CCC"
- `get-decimals()` - Returns 6
- `get-token-uri()` - Returns metadata URI
- `get-total-supply()` - Returns total token supply

#### Balance & Status Queries
- `get-balance(user: principal)` - Get user's token balance
- `is-coffee-shop(shop: principal)` - Check if address is registered coffee shop
- `get-remaining-daily-claims(user: principal)` - Get remaining daily claims for user
- `get-rewards-pool()` - Get current reward pool balance
- `get-daily-reward()` - Get daily reward amount (1 CCC)

## Deployment Guide

### Development Network (Devnet)

1. **Start local devnet**:
   ```bash
   clarinet integrate
   ```

2. **Deploy contract**:
   ```bash
   clarinet deploy --devnet
   ```

### Testnet Deployment

1. **Configure testnet settings** in `settings/Testnet.toml`

2. **Deploy to testnet**:
   ```bash
   clarinet deploy --testnet
   ```

### Mainnet Deployment

1. **Configure mainnet settings** in `settings/Mainnet.toml`

2. **Deploy to mainnet**:
   ```bash
   clarinet deploy --mainnet
   ```

**⚠️ Important**: Thoroughly test on devnet and testnet before mainnet deployment.

## Security Considerations

### Built-in Protections

- **Daily Limits**: Maximum 3 reward claims per day per customer
- **Time-based Tracking**: Uses block height to determine daily reset periods
- **Coffee Shop Validation**: Only registered shops can distribute rewards
- **Owner Controls**: Critical functions restricted to contract owner
- **Balance Checks**: Prevents reward distribution when pool is insufficient

### Security Best Practices

1. **Multi-signature Wallet**: Use a multi-sig wallet for contract ownership
2. **Gradual Rollout**: Start with limited coffee shop registrations
3. **Regular Monitoring**: Monitor reward distributions and pool balance
4. **Emergency Procedures**: Have plans for pausing rewards if needed
5. **Code Audits**: Consider professional security audits before mainnet deployment

### Known Limitations

- **Block Time Variance**: Daily calculations assume 10-minute blocks (may vary)
- **No Pause Function**: Contract doesn't include emergency pause functionality
- **Fixed Reward Amount**: Daily reward amount is hardcoded (1 CCC)

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `err-owner-only` | Function restricted to contract owner |
| 101 | `err-not-authorized` | Unauthorized transfer attempt |
| 102 | `err-insufficient-balance` | Insufficient balance in rewards pool |
| 103 | `err-already-claimed-today` | Daily claim limit exceeded |
| 104 | `err-shop-not-registered` | Coffee shop not registered |
| 105 | `err-invalid-amount` | Invalid amount specified |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

1. **Make changes** to the contract or tests
2. **Run tests**: `npm test`
3. **Check syntax**: `clarinet check`
4. **Test deployment**: `clarinet integrate`
5. **Submit PR** with comprehensive description

## License

This project is licensed under the ISC License - see the package.json file for details.

## Contact & Support

- **Documentation**: [Clarity Language Reference](https://docs.stacks.co/clarity)
- **Stacks Blockchain**: [docs.stacks.co](https://docs.stacks.co)
- **Issues**: Please use GitHub Issues for bug reports and feature requests

---

**Disclaimer**: This smart contract is provided as-is. Please conduct thorough testing and consider professional audits before deploying to mainnet with real value.