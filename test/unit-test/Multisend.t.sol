// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../lib/forge-std/src/Test.sol";
import "../../src/Multisend.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("MockToken", "MKT") {
    _mint(msg.sender, 1000 * 10 ** 18); // Mint 1000 tokens to the deployer
  }
}

contract MultisendTest is Test {
  Multisend public multisend;
  MockERC20 public token;
  address public owner;

  function setUp() public {
    owner = vm.addr(1);
    vm.prank(owner);

    multisend = new Multisend();
    token = new MockERC20();
  }

  function testMultiSendEther() public {
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(0xBEEF);
    recipients[1] = vm.addr(0xBEEA);

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1 ether;
    amounts[1] = 2 ether;

    // Ensure this contract has enough Ether for the test
    vm.deal(address(this), 3 ether);

    // Call the multiSendEther function and send Ether
    multisend.multiSendEther{value: 3 ether}(recipients, amounts);

    assertEq(uint256(recipients[0].balance), 1 ether, "Recipient 1 did not receive 1 ether");
    assertEq(uint256(recipients[1].balance), 2 ether, "Recipient 2 did not receive 2 ether");
  }

  function testMultiSendToken() public {
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(1);
    recipients[1] = vm.addr(2);

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 100 * 10 ** 18; // 100 tokens with 18 decimals
    amounts[1] = 200 * 10 ** 18; // 200 tokens

    // Approve the Multisend contract to spend tokens
    token.approve(address(multisend), 300 * 10 ** 18);

    // Call the multiSendToken function to transfer tokens
    multisend.multiSendToken(address(token), recipients, amounts);

    // Check that recipients received the correct token amounts
    assertEq(token.balanceOf(recipients[0]), 100 * 10 ** 18);
    assertEq(token.balanceOf(recipients[1]), 200 * 10 ** 18);
  }

  function testMultiSendTokenMismatchedArrays() public {
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(1);
    recipients[1] = vm.addr(2);

    uint256[] memory amounts = new uint256[](1);
    amounts[0] = 100 * 10 ** 18;

    // Approve tokens to be transferred
    token.approve(address(multisend), 300 * 10 ** 18);

    // Expect a revert due to mismatched array lengths
    vm.expectRevert("Recipients and amounts must be the same length");
    multisend.multiSendToken(address(token), recipients, amounts);
  }

  function testMultiSendEtherInsufficientValue() public {
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(1);
    recipients[1] = vm.addr(2);

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1 ether;
    amounts[1] = 2 ether;

    // Ensure this contract has 2 ether, which is less than required
    vm.deal(address(this), 2 ether);

    // Expect a revert due to insufficient Ether value
    vm.expectRevert("Not enough Ether provided");
    multisend.multiSendEther{value: 2 ether}(recipients, amounts);
  }

  function testMultiSendTokenInsufficientAllowance() public {
    address[] memory recipients = new address[](2);
    recipients[0] = vm.addr(1);
    recipients[1] = vm.addr(2);

    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 100 * 10 ** 18;
    amounts[1] = 200 * 10 ** 18;

    // Approve only 200 tokens instead of 300
    token.approve(address(multisend), 200 * 10 ** 18);

    // Expect a revert due to insufficient allowance
    vm.expectRevert("Insufficient token allowance");
    multisend.multiSendToken(address(token), recipients, amounts);
  }

  function testWithdrawEther() public {
    vm.deal(address(multisend), 1 ether);

    assertEq(address(multisend).balance, 1 ether, "Contract should have 1 Ether before withdrawal");

    vm.prank(owner);

    multisend.withdrawEther();

    assertEq(address(multisend).balance, 0, "Contract should have 0 Ether left");
  }

  function testWithdrawTokens() public {
    token.transfer(address(multisend), 300 * 10 ** 18);

    assertEq(token.balanceOf(address(multisend)), 300 * 10 ** 18, "Contract should have 300 tokens");

    // Simulate the owner withdrawing tokens from the contract
    vm.prank(owner);
    multisend.withdrawTokens(address(token), 300 * 10 ** 18);

    // Check if the contract has 0 tokens left after withdrawal
    assertEq(token.balanceOf(address(multisend)), 0, "Contract should have 0 tokens left");

    // Check if the owner received the tokens
    assertEq(token.balanceOf(owner), 300 * 10 ** 18, "Owner should have received 300 tokens");
  }
}

