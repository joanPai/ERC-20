// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// imports
import {Script, console} from "lib/forge-std/src/Script.sol";
import {TokenContract} from "src/TokenContract.sol";

// contract
contract DeployTokenContract is Script {
    function run() public returns (TokenContract) {
        vm.startBroadcast();
        TokenContract token = new TokenContract(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        console.log("Token deployed at address: ", address(token));
        vm.stopBroadcast();
        return token;
    }
}
