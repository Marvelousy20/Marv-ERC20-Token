// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MarvToken is ERC20 {
    string private tokenName = "MarvToken";
    string private tokenSymbol = "MRK";

    constructor(uint256 initialSupply) ERC20(tokenName, tokenSymbol) {
        _mint(msg.sender, initialSupply);
    }
}
