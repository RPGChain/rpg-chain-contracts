// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DiceTower {
    address payable creatorWallet;
    IERC20 private _d20TokenContractAddress;

    constructor() {
        creatorWallet = payable(msg.sender);
    }

    function setD20TokenContractAddress(IERC20 d20TokenContractAddress) public {
        require(msg.sender == creatorWallet);
        _d20TokenContractAddress = d20TokenContractAddress;
    }

    function getD20TokenContractAddress() public view returns (IERC20) {
        return _d20TokenContractAddress;
    }

    function name() public pure returns (string memory) {
        return "DiceTower";
    }

    receive() external payable {
        // Require the correct token(s) [D20]
        // Role the dice and return the funds
    }

    function roll() external payable {
        //emit Rolled(var);
    }
}
