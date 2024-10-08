// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Multisend} from "../src/Multisend.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract MultisendDeploy is Script {
  function run() external {
    // Load private key from environment variable
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions using the deployer's private key
    vm.startBroadcast(deployerPrivateKey);

    // Deploy the contract
    Multisend multisend = new Multisend();

    // Log the address of the deployed contract
    console.log("Multisend deployed at:", address(multisend));

    vm.stopBroadcast();
  }
}
