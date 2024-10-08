// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {MockUSDT} from "../test/mocks/MockUSDT.sol";

contract MintMoreUSD is Script {
  // Constants for token deployment
  address internal constant TOKEN_ADDRESS = 0x78E97B219B3f827b17947127193749079A684474;
  uint256 internal constant AMOUNT_MINT = 100_000 * 10 ** 18; // 100,000 USDT
  address internal owner;

  function run() external {
    // Retrieve the owner's private key from environment variables
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    owner = vm.addr(privateKey);

    // Start broadcasting transactions from the owner's address
    vm.startBroadcast(privateKey);

    // Initialize the MockUSDT contract at the pre-deployed address
    MockUSDT usdt = MockUSDT(TOKEN_ADDRESS);

    // Mint 100,000 USDT tokens to the owner's address
    usdt.mint(AMOUNT_MINT);

    // Log the important information after minting
    console.log("MintMoreUSD: Minted", AMOUNT_MINT / 10 ** 18, "USDT to the owner's address:", owner);
    console.log("Owner's USDT balance after minting:", usdt.balanceOf(owner) / 10 ** 18, "USDT");

    // End broadcasting
    vm.stopBroadcast();
  }
}
