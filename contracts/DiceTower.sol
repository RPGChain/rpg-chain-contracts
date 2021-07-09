// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DiceTower {
    address payable creatorWallet;
    IERC20 private _d20TokenContractAddress;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        private _rolls; // _rolls[sender][d20][rollId] = roll result

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

    function rollDiceD20() external payable {
        require(
            _d20TokenContractAddress.allowance(msg.sender, address(this)) > 0
        );
        require(
            _d20TokenContractAddress.transferFrom(msg.sender, address(this), 1)
        );
        uint256 rollId = 1; //TODO - get length of rolls from this address
        _rollDice(msg.sender, rollId, 20);
        // TODO - Return Dice
        //emit Rolled(rollId);
    }

    function _rollDice(
        address sender,
        uint256 rollId,
        uint256 diceType
    ) private {
        // TODO - Roll random value based on diceType
        //mapping roll;
        // TODO - Store roll
        //_rolls.push();
    }
}
