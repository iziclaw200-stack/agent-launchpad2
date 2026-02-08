// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AirdropDistributor
 * @author dbmox.protocol
 * @notice A contract to securely manage and distribute ERC20 token airdrops.
 * The owner sets allocations, and eligible users can claim their tokens.
 */
contract AirdropDistributor is Ownable, ReentrancyGuard {
    IERC20 public immutable token;
    
    mapping(address => uint256) public allocations;
    mapping(address => bool) public hasClaimed;

    event Claimed(address indexed recipient, uint256 amount);
    event AllocationsSet(uint256 totalRecipients);
    event UnclaimedTokensWithdrawn(address indexed to, uint256 amount);

    /**
     * @param _tokenAddress The address of the ERC20 token to be distributed.
     */
    constructor(address _tokenAddress) Ownable(msg.sender) {
        require(_tokenAddress != address(0), "Token cannot be the zero address");
        token = IERC20(_tokenAddress);
    }

    /**
     * @notice Sets the airdrop allocations for multiple recipients.
     * @dev Can only be called by the owner. This will overwrite existing allocations.
     * @param recipients An array of recipient addresses.
     * @param amounts An array of token amounts corresponding to each recipient.
     */
    function setAllocations(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Arrays must have the same length");

        for (uint256 i = 0; i < recipients.length; i++) {
            allocations[recipients[i]] = amounts[i];
        }
        
        emit AllocationsSet(recipients.length);
    }

    /**
     * @notice Allows a user to claim their allocated tokens.
     * @dev Reverts if the user has no allocation or has already claimed.
     */
    function claim() external nonReentrant {
        uint256 amount = allocations[msg.sender];
        require(amount > 0, "No allocation for this address");
        require(!hasClaimed[msg.sender], "Tokens already claimed");

        hasClaimed[msg.sender] = true;
        
        require(token.transfer(msg.sender, amount), "Token transfer failed");

        emit Claimed(msg.sender, amount);
    }

    /**
     * @notice Allows the owner to withdraw any remaining tokens after the airdrop period.
     * @dev This should be used to recover unclaimed funds.
     */
    function withdrawUnclaimedTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        emit UnclaimedTokensWithdrawn(owner(), balance);
        
        require(token.transfer(owner(), balance), "Token transfer failed");
    }
}
