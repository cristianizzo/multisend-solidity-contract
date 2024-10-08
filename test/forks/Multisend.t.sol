// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../lib/forge-std/src/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Multisend} from "../../src/Multisend.sol";

contract MultisendIntegrationTest is Test {
  IERC20 public usdt;
  address payable public multisendAddress = payable(0x82204D12C5F1Cf8D722dE9C79A5Aa0bfD45eFAcD); // Deployed Multisend contract on BSC
  address public usdtAddress = 0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA; // USDT token contract
  address public ownerAddress = 0x58083a6f443c5ac8456CAe5c429E974B82C833fE; // Owner of the Multisend contract

  function setUp() public {
    usdt = IERC20(usdtAddress);
    vm.label(ownerAddress, "Owner");
  }

  function testMultiSendTokenInteg() public {
    // Fund the owner with 10,000 USDT for testing
    deal(address(usdt), ownerAddress, 10000 * 10 ** 18);

    // Log initial owner balance
    console.log("Owner's initial balance:", usdt.balanceOf(ownerAddress));

    // Check initial owner balance
    assertEq(usdt.balanceOf(ownerAddress), 10000 * 10 ** 18, "Owner should have 10k USDT initially");

    // Prank the owner for this transaction
    vm.startPrank(ownerAddress);

    // Prepare recipients and amounts
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(1); // Recipient 1
    recipients[1] = vm.addr(2); // Recipient 2

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 7000 * 10 ** 18; // 7,000 USDT
    amounts[1] = 3000 * 10 ** 18; // 3,000 USDT

    // Approve the Multisend contract to spend 10,000 USDT
    usdt.approve(multisendAddress, 10000 * 10 ** 18);

    // Call the multisend contract to distribute tokens
    Multisend(multisendAddress).multiSendToken(usdtAddress, recipients, amounts);

    // Stop the prank (reverts back from owner mode)
    vm.stopPrank();

    // Log final owner balance
    console.log("Owner's final balance:", usdt.balanceOf(ownerAddress));

    // Validate final balances
    assertEq(usdt.balanceOf(ownerAddress), 0, "Owner should have 0 USDT after sending");
    assertEq(usdt.balanceOf(recipients[0]), 7000 * 10 ** 18, "Recipient 1 should have 7k USDT");
    assertEq(usdt.balanceOf(recipients[1]), 3000 * 10 ** 18, "Recipient 2 should have 3k USDT");

    // Log recipient balances
    console.log("Recipient 1 final balance:", usdt.balanceOf(recipients[0]));
    console.log("Recipient 2 final balance:", usdt.balanceOf(recipients[1]));
  }
}
