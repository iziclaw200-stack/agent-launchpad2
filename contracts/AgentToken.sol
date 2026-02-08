// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AgentToken
 * @author dbmox.protocol
 * @notice A standard, gas-efficient ERC20 contract for autonomous agent tokens.
 * Features a built-in fee mechanism to fund agent operations and a total supply cap.
 */
contract AgentToken is ERC20, Ownable {
    address public agentWallet;
    uint256 public feePercentage; // Fee represented as a basis point, e.g., 100 = 1%

    event FeeWalletUpdated(address indexed newWallet);
    event FeePercentageUpdated(uint256 indexed newFee);

    /**
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param initialSupply_ The total initial supply of the token (e.g., 1_000_000 * 10**18).
     * @param _agentWallet The wallet address that will receive the fees.
     * @param _feePercentage The fee on transfers in basis points (1% = 100). Max 500 (5%).
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address _agentWallet,
        uint256 _feePercentage
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(_agentWallet != address(0), "Agent wallet cannot be the zero address");
        require(_feePercentage <= 500, "Fee cannot exceed 5%"); // Capped at 5%
        
        _mint(msg.sender, initialSupply_);
        agentWallet = _agentWallet;
        feePercentage = _feePercentage;
    }

    /**
     * @dev See {IERC20-transfer}.
     * Includes a fee mechanism on transfers.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 feeAmount = 0;
        if (feePercentage > 0) {
            feeAmount = (amount * feePercentage) / 10000;
        }

        uint256 transferAmount = amount - feeAmount;

        // Perform the main transfer
        super._transfer(from, to, transferAmount);

        // Transfer the fee to the agent wallet, if applicable
        if (feeAmount > 0) {
            super._transfer(from, agentWallet, feeAmount);
        }
    }

    /**
     * @notice Updates the wallet that receives agent fees.
     * @param newWallet The new address for the agent wallet.
     */
    function setAgentWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "New wallet cannot be the zero address");
        agentWallet = newWallet;
        emit FeeWalletUpdated(newWallet);
    }

    /**
     * @notice Updates the fee percentage.
     * @param newFee The new fee in basis points (e.g., 150 for 1.5%).
     */
    function setFeePercentage(uint256 newFee) external onlyOwner {
        require(newFee <= 500, "Fee cannot exceed 5%");
        feePercentage = newFee;
        emit FeePercentageUpdated(newFee);
    }
}
