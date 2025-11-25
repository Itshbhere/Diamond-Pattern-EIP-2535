# Diamond Pattern Implementation (EIP-2535)

This project implements the Diamond Pattern (EIP-2535), a proxy pattern that allows you to upgrade smart contracts by adding, replacing, or removing functionality through facets without changing the contract address.

## What is the Diamond Pattern?

The Diamond Pattern enables **upgradeable smart contracts** where:
- The **Diamond** contract acts as a proxy with a single address
- **Facets** are separate contracts containing the actual function implementations
- Functions are routed to facets using **delegatecall** based on function selectors
- You can add, replace, or remove functions without changing the Diamond's address

## Architecture Overview

### Key Components

1. **Diamond Contract** (`src/Diamond.sol`)
   - The main proxy contract that users interact with
   - Uses a `fallback()` function to route calls to appropriate facets
   - Stores a mapping of function selectors to facet addresses
   - All state is stored in a shared storage location (DiamondStorage)

2. **DiamondCutFacet** (`src/DiamondCut.sol`)
   - The facet that handles adding/replacing functions
   - Only the contract owner can call `diamondCut()`
   - Registers new function selectors and their corresponding facet addresses

3. **CounterFacet** (`src/Facet.sol`)
   - Example facet with counter functionality
   - Contains `increment()`, `decrement()`, and `getCount()` functions
   - Demonstrates how facets can be added to the Diamond

4. **DiamondStorage** (`src/DiamondStorage.sol`)
   - Library that manages shared storage using EIP-2535 Diamond Storage pattern
   - Uses a fixed storage slot to avoid storage collisions
   - Stores the selector-to-facet mapping and contract owner

## How It Works

### 1. Deployment Flow

When you deploy the Diamond:

```solidity
// 1. Deploy DiamondCutFacet (the facet that manages upgrades)
DiamondCutFacet diamondCutFacet = new DiamondCutFacet();

// 2. Deploy Diamond (the proxy contract)
Diamond diamond = new Diamond(owner, address(diamondCutFacet));

// 3. Deploy CounterFacet (example functionality)
CounterFacet counterFacet = new CounterFacet();

// 4. Register CounterFacet functions with the Diamond
IDiamondCut(address(diamond)).diamondCut(
    address(counterFacet),
    [increment.selector, decrement.selector, getCount.selector]
);
```

### 2. Function Routing

When a function is called on the Diamond:

1. The `fallback()` function is triggered (since Diamond doesn't implement the function directly)
2. It looks up the function selector (`msg.sig`) in the `selectorToFacet` mapping
3. It performs a `delegatecall` to the corresponding facet address
4. The facet executes in the context of the Diamond's storage
5. The result is returned to the caller

### 3. Storage Pattern

All facets share the same storage through **Diamond Storage**:
- Uses a fixed storage slot: `keccak256("diamond.standard.diamond.storage")`
- Prevents storage collisions between facets
- Allows facets to access shared state (like `count` in CounterFacet)

## Project Structure

```
src/
├── Diamond.sol           # Main Diamond proxy contract
├── DiamondCut.sol        # Facet for managing upgrades
├── DiamondStorage.sol    # Shared storage library
├── Facet.sol             # Example CounterFacet
└── interfaces/
    ├── IDiamond.sol      # Diamond interface definitions
    └── IDiamondCut.sol   # Alternative EIP-2535 interface (not used)

script/
└── Diamond.s.sol         # Deployment script
```

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Deploy

```shell
forge script script/Diamond.s.sol:DiamondScript \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify
```

### Interact with the Diamond

After deployment, use the interaction script to call functions on the deployed Diamond:

**Using environment variable:**
```shell
export DIAMOND_ADDRESS=0xYourDiamondAddress
forge script script/InteractDiamond.s.sol:InteractDiamondScript \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

**Or inline:**
```shell
DIAMOND_ADDRESS=0xYourDiamondAddress forge script script/InteractDiamond.s.sol:InteractDiamondScript \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

**Read-only calls (no broadcast):**
```shell
DIAMOND_ADDRESS=0xYourDiamondAddress forge script script/InteractDiamond.s.sol:InteractDiamondScript \
    --rpc-url $SEPOLIA_RPC_URL
```

The script will:
- Get the current count
- Call `increment()` twice
- Call `decrement()` once
- Display the final count

## Key Features

- ✅ **Upgradeable**: Add new functions without changing the contract address
- ✅ **Modular**: Separate concerns into different facets
- ✅ **Gas Efficient**: Uses delegatecall, no storage duplication
- ✅ **Owner Controlled**: Only owner can add/replace functions
- ✅ **Storage Safe**: Diamond Storage pattern prevents collisions

## Important Notes

- The Diamond contract uses the **simplified interface** from `DiamondCut.sol`, not the full EIP-2535 interface
- All facets must use the same storage layout (Diamond Storage pattern)
- Only the contract owner can call `diamondCut()` to modify functions
- Function selectors must be unique across all facets

## Foundry Commands

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Anvil (Local Node)

```shell
anvil
```

### Cast

```shell
cast <subcommand>
```

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
