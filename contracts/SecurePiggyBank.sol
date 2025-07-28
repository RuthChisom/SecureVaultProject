// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecurePiggyBank - A secure version of the vulnerable piggy bank contract
/// @author Ruth Chisom
/// @notice This contract allows ETH deposits and only the contract owner to withdraw
/// @dev Fixes multiple critical vulnerabilities: access control, reentrancy, unchecked calls

contract SecurePiggyBank {
    /// @notice Address of the contract owner
    address public owner;

    /// @notice Reentrancy guard state variable
    bool internal locked;

    /// @dev Modifier to restrict function access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @dev Modifier to prevent reentrancy attacks using the "Checks-Effects-Interactions" pattern
    modifier nonReentrant() { 
        require(!locked, "No reentrancy"); //Blocks recursive calls in fallback/receive attacks.
        locked = true;
        _;
        locked = false;
    }

    /// @notice Sets the deployer as the contract owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Allows anyone to deposit ETH into the contract
    /// @dev No logic needed here; function is `payable` to receive ETH
    function deposit() public payable {}

    /// @notice Allows the contract owner to withdraw all ETH from the contract
    /// @dev Implements access control and reentrancy protection
    function withdraw() public onlyOwner nonReentrant {
        uint balance = address(this).balance;

        require(balance > 0, "No balance to withdraw");

        // Secure way to transfer ETH — using call, with a success check
        (bool sent, ) = payable(owner).call{value: balance}("");
        require(sent, "Withdraw failed");
    }
}
