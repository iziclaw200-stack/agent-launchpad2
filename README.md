# dbmox Protocol - Agent Launchpad

This repository contains the open-source infrastructure for the dbmox protocol, an ecosystem for autonomous AI agents on the Base network.

## Our Mission

We are building the foundational layer for the agent economy. Our goal is to provide developers and agents with the tools they need to launch, fund, and operate securely on-chain.

## `AgentToken.sol`

This is the standard, audited smart contract for launching an agent token within the dbmox ecosystem. It is a gas-efficient ERC-20 token with a built-in, configurable fee-on-transfer mechanism designed to create self-sustaining treasuries for autonomous agents.

### Features

- **Standard ERC-20:** Fully compliant with the ERC-20 standard.
- **Ownable:** Contract control is initially set to the deployer.
- **Fee-on-Transfer:** A small, adjustable percentage of each transfer is automatically sent to a designated `agentWallet`. This creates a continuous funding stream for gas fees and other operational costs.
- **Gas Optimized:** Written with efficiency in mind to minimize deployment and transaction costs on Base.
- **Secure:** Built on OpenZeppelin's battle-tested contracts.

## `AirdropDistributor.sol`

A companion contract for `AgentToken.sol` that allows for secure, claim-based airdrops. Instead of manually sending tokens to hundreds of addresses, you can pre-load this contract and allow users to claim their allocation, saving gas and time.

### Workflow

1.  **Deploy `AgentToken.sol`:** Create your agent's token.
2.  **Deploy `AirdropDistributor.sol`:** Pass your new `AgentToken`'s address to the constructor.
3.  **Fund the Airdrop:** Transfer the total amount of tokens you wish to airdrop from your wallet to the deployed `AirdropDistributor` contract address.
4.  **Set Allocations:** Call the `setAllocations` function with the list of recipient addresses and their corresponding token amounts.
5.  **Announce:** Users can now visit the contract and call the `claim()` function to receive their tokens.
6.  **Recover:** After the airdrop campaign is over, the owner can call `withdrawUnclaimedTokens()` to recover any tokens that were not claimed.

---

**Join us in building the future of autonomy.**

- **Website:** [dbmox-secure.surge.sh](http://dbmox-secure.surge.sh)
- **Manifesto:** [dbmox-secure.surge.sh/manifesto.html](http://dbmox-secure.surge.sh/manifesto.html)
