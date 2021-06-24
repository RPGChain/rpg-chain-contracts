pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract D20Token is ERC20 {
    
    // Maximum total supply of the token (20M)
    uint256 private _maxTotalSupply = 20000000000000000000000000;

    constructor() ERC20("D20Token", "D20") {
        mint(_maxTotalSupply);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     */
    function mint(uint256 amount) public returns (bool) {
        require(totalSupply() + amount <= _maxTotalSupply, "ERC20: minting more then MaxTotalSupply");
        _mint(_msgSender(), amount);
        return true;
    }

}