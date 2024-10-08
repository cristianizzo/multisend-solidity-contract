// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
  address public owner;

  constructor(uint256 initialSupply) ERC20("Tether USD", "USDT") {
    owner = msg.sender;
    _mint(msg.sender, initialSupply);
  }

  // Function to mint more tokens (anyone can mint)
  function mint(uint256 amount) public {
    _mint(msg.sender, amount);
  }
}
