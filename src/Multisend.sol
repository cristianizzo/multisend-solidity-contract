// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.8;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Script, console2} from "forge-std/Script.sol";

/// @title Multisend
/// @author CristianoIzzo - 2024
contract Multisend is Ownable {
  using SafeERC20 for IERC20;

  event MultiSendEtherSuccessful(address indexed from, address[] recipients, uint256[] amounts);
  event MultiSendTokenSuccessful(address indexed from, address[] recipients, uint256[] amounts, address token);

  constructor() Ownable(msg.sender) {}

  // Function to send native currency (like Ether) to multiple addresses
  function multiSendEther(address[] calldata recipients, uint256[] calldata amounts) external payable {
    require(recipients.length == amounts.length, "Recipients and amounts must be the same length");

    uint256 totalAmount = 0;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmount += amounts[i];
    }
    require(totalAmount == msg.value, "Not enough Ether provided");

    for (uint256 i = 0; i < recipients.length; i++) {
      payable(recipients[i]).transfer(amounts[i]);
    }

    emit MultiSendEtherSuccessful(msg.sender, recipients, amounts);
  }

  // Function to send ERC20 tokens to multiple addresses
  function multiSendToken(address token, address[] calldata recipients, uint256[] calldata amounts) external {
    require(recipients.length == amounts.length, "Recipients and amounts must be the same length");

    IERC20 tokenContract = IERC20(token);

    uint256 totalAmount = 0;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmount += amounts[i];
    }

    require(tokenContract.allowance(msg.sender, address(this)) >= totalAmount, "Insufficient token allowance");

    for (uint256 i = 0; i < recipients.length; i++) {
      tokenContract.safeTransferFrom(msg.sender, recipients[i], amounts[i]);
    }

    emit MultiSendTokenSuccessful(msg.sender, recipients, amounts, token);
  }

  // Function to withdraw stuck ERC20 tokens
  function withdrawTokens(address _token, uint256 _amount) external onlyOwner {
    IERC20 tokenContract = IERC20(_token);
    require(tokenContract.balanceOf(address(this)) >= _amount, "Insufficient token balance in contract");
    tokenContract.safeTransfer(owner(), _amount);
  }

  function withdrawEther() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No Ether to withdraw");

    payable(msg.sender).transfer(balance);
  }


  // Fallback function to receive Ether
  receive() external payable {
  }

}

