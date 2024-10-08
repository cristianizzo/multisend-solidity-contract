// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {Multisend} from "../src/Multisend.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSend is Script {
  address internal owner;

  // Define recipient addresses and amounts
  address[] internal recipientAddresses = [
    0x1234567890123456789012345678901234567890,
    0x0987654321098765432109876543210987654321
  ];

  uint256[] internal amounts = [
    70000 * 10 ** 18,  // 70,000 USDT
    30000 * 10 ** 18   // 30,000 USDT
  ];

  // Define total amount to distribute (100k USDT)
  uint256 internal constant TOTAL_DISTRIBUTION = 100000 * 10 ** 18; // 100,000 USDT

  function run() external {
    // Load owner private key from the environment
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
    address multisendContractAddress = vm.envAddress("MULTISEND_ADDRESS");

    owner = vm.addr(privateKey);
    console.log("Owner", owner);

    // Initialize the Multisend contract and token contract
    Multisend multisend = Multisend(payable(multisendContractAddress));
    IERC20 token = IERC20(tokenAddress);

    // Check the owner's initial balance
    uint256 ownerInitialBalance = token.balanceOf(owner);
    console.log("Owner's initial USDT balance:", ownerInitialBalance);

    // Broadcasting the transaction
    vm.startBroadcast(privateKey);

    // Approve the multisend contract to spend the total amount of tokens
    uint256 totalAmount = 100000 * 10 ** 18;  // 100k USDT
    token.approve(multisendContractAddress, totalAmount);

    // Verify allowance before proceeding
    uint256 allowance = token.allowance(owner, multisendContractAddress);
    console.log("Allowance for multisend contract:", allowance);

    if (allowance < totalAmount) {
      console.log("Error: Insufficient allowance. Exiting.");
      vm.stopBroadcast();
      return;
    }

    // Call the multisend contract to distribute tokens
    multisend.multiSendToken(tokenAddress, recipientAddresses, amounts);

    vm.stopBroadcast();

    // Log the owner's final balance
    uint256 ownerFinalBalance = token.balanceOf(owner);
    console.log("Owner's final USDT balance:", ownerFinalBalance);

    // Loop through recipients and log the new balances
    for (uint256 i = 0; i < recipientAddresses.length; i++) {
      uint256 newBalance = token.balanceOf(recipientAddresses[i]);
      console.log("Recipient", recipientAddresses[i], "new balance:", newBalance);
    }
  }
}
