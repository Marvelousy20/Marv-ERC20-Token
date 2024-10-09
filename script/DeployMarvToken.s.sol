// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MarvToken} from "src/MarvToken.sol";

contract DeployMarvToken is Script {
    MarvToken public marvToken;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (MarvToken) {
        vm.startBroadcast();
        marvToken = new MarvToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return marvToken;
    }
}
