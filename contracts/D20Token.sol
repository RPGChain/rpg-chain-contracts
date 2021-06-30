// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract D20Token is ERC20, ERC20Burnable {
    // Owner wallet
    address payable wallet;
    // Maximum total supply of the token (20M)
    uint256 private _maxTotalSupply = 20000000000000000000000000;

    constructor() ERC20("D20Token", "D20") {
        wallet = payable(msg.sender);
        mint(_maxTotalSupply);
    }

    function mint(uint256 amount) public returns (bool) {
        require(
            totalSupply() + amount <= _maxTotalSupply,
            "ERC20: minting more then MaxTotalSupply"
        );

        _mint(_msgSender(), amount);
        return true;
    }

    function withdrawalToWallet() public payable {
        require(msg.sender == wallet);
        address(this).balance;
        wallet.transfer(address(this).balance);
    }
}
