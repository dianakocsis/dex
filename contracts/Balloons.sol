//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Balloons - A simple ERC20 token with a fixed supply
contract Balloons is ERC20 {

    /// @notice Initializes the contract with a fixed supply of 1000 tokens
    constructor() ERC20("Balloons", "BAL") {
        _mint(msg.sender, 1000 ether);
    }
}
