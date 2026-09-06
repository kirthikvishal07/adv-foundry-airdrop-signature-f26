# Merkle Airdrop

A Solidity project built while following Section 5, **Airdrop and Signature**, of the Cyfrin Updraft Advanced Foundry course. It shows how an ERC-20 airdrop can use a Merkle tree to verify an allowlist on-chain without storing every eligible address in contract storage.

> Note: the current contract implements Merkle-proof claims. Signature-based claims are not implemented in this repository.

## What it does

- Deploys a mintable `BagelToken` (`BAGEL`) ERC-20 token.
- Deploys a `MerkleAirdrop` contract with an immutable Merkle root and token address.
- Funds the airdrop contract with the allotted tokens.
- Lets an eligible account claim its allocation by submitting its amount and Merkle proof.
- Rejects invalid proofs and duplicate claims.

## Project layout

```text
src/
  BagelToken.sol                 # ERC-20 token used for the distribution
  MerkleAirdrop.sol              # Merkle-proof airdrop contract
script/
  GenerateInput.s.sol            # Creates allowlist input JSON
  MakeMerkle.s.sol                # Creates Merkle root and proofs from that input
  DeployMerkleAirdrop.s.sol      # Deploys and funds both contracts
test/
  MerkleAirdrop.t.sol            # Claim-flow test
```

## How claiming works

For each eligible recipient, the off-chain Merkle tree is built from the hashed `(account, amount)` pair. The recipient calls:

```solidity
claim(account, amount, merkleProof)
```

The contract reconstructs the leaf, verifies the proof against the deployed Merkle root, records the account as claimed, and safely transfers the specified BAGEL amount.

## Getting started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Install

```bash
git clone <your-repository-url>
cd adv-foundry-merkle-drop
forge install
```

### Build and test

```bash
forge build
forge test
```

For verbose test output:

```bash
forge test -vvv
```

## Generate Merkle data

The scripts use four sample allowlist addresses, each allocated `25e18` tokens.

```bash
forge script script/GenerateInput.s.sol:GenerateInput
forge script script/MakeMerkle.s.sol:MakeMerkle
```

This produces:

- `script/target/input.json` - allowlist input
- `script/target/output.json` - Merkle root, leaves, and claim proofs

If you change the allowlist or allocation amount, regenerate the data and update the root used by the deployment script before deploying.

## Deploy

Set an RPC URL and private key in your environment, then broadcast the deployment:

```bash
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

The deployment script creates the BAGEL token and airdrop contract, mints `100 BAGEL`, and transfers those tokens to the airdrop contract for the four sample claims.

## Contracts

| Contract | Purpose |
| --- | --- |
| `BagelToken` | Owner-mintable ERC-20 token named Bagel (`BAGEL`). |
| `MerkleAirdrop` | Verifies Merkle proofs and distributes the configured ERC-20 allocation once per account. |

## Security notes

- The Merkle root and token address are immutable after deployment.
- Claims use OpenZeppelin's `MerkleProof` and `SafeERC20` utilities.
- An address may successfully claim only once.
- Treat the allowlist, Merkle root, proofs, private key, and RPC endpoint as deployment-sensitive data; validate them before broadcasting to a live network.

## License

This project is licensed under the MIT License.
# adv-foundry-airdrop-signature-f26
