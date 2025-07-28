# SecureVaultProject
A simple audited smart contract that allows ETH deposits and owner-only withdrawals. Fixed common vulnerabilities like:

- Missing access control
- Reentrancy
- Poor error handling

<!--  Initial vulnerable code

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract VulnerablePiggyBank {
    address public owner;
    constructor() { owner = msg.sender }
    function deposit() public payable {}
    function withdraw() public { payable(msg.sender).transfer(address(this).balance); }
    function attack() public { }
}
 -->

Includes an Attacker contract to simulate the exploit.

## Security Fixes

- Added `onlyOwner` modifier to protect `withdraw()`
- Added `nonReentrant` lock to prevent reentrancy
- Used `call` with error checks instead of `transfer`

## How to Run (Hardhat)

1. Clone the repo
2. Install deps: `npm install`
3. Compile: `npx hardhat compile`
4. Run tests or scripts


## 🔍 Attack Flow Breakdown
- attack() sends 0.1 ETH to VulnerablePiggyBank and immediately calls withdraw().
- During withdraw(), the target sends ETH back to Attacker.
- When Attacker receives ETH, its receive() function triggers — calling withdraw() again, before the original withdraw() call finishes.
- This loops as long as the target has enough ETH, draining the contract.

## 🧪 How to Test It
You can test this in a Hardhat/Remix project by:
- Deploying the original vulnerable contract
- Deploying the Attacker with the vulnerable contract’s address
- Calling attack() with 0.1 ETH from the attacker contract

## ✅ What Happens on the Fixed Contract?
The attack fails completely if you try it against SecurePiggyBank because:
- Only the owner can call withdraw()
- nonReentrant modifier prevents recursive calls

