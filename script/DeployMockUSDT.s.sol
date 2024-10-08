// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {MockUSDT} from "../test/mocks/MockUSDT.sol";

contract DeployMockUSDT is Script {
  uint256 internal constant INITIAL_SUPPLY = 100000 * 10 ** 18; // 100,000 USDT
  address internal owner;

  function run() external {
    // Load the owner's private key from the environment
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    owner = vm.addr(privateKey);

    // Broadcast the deployment transaction
    vm.startBroadcast(privateKey);

    // Deploy the MockUSDT contract with an initial supply of 100,000 USDT
    MockUSDT usdt = new MockUSDT(INITIAL_SUPPLY);
    console.log("Mock USDT deployed at:", address(usdt));
    console.log("Owner's initial USDT balance:", usdt.balanceOf(owner));

    vm.stopBroadcast();
  }
}
