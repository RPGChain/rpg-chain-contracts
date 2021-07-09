// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DiceTower {
    address payable creatorWallet;
    IERC20 private _d20TokenContractAddress;

    mapping(address => uint256[]) private _rolls;
    mapping(address => uint256) private _rollCounts;

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
            _d20TokenContractAddress.allowance(msg.sender, address(this)) > 0,
            "allowance"
        );
        require(
            _d20TokenContractAddress.transferFrom(
                msg.sender,
                address(this),
                1000000000000000000
            ),
            "fail send"
        );
        uint256 rollId = _rollCounts[msg.sender];
        _rollDice(msg.sender, 20);
        // TODO - Return Dice
        //emit Rolled(rollId);
    }

    function getRollsForAccount(address account)
        public
        view
        returns (uint256[] memory)
    {
        return _rolls[account];
    }

    function getRollForAccount(address account, uint256 id)
        public
        view
        returns (uint256)
    {
        return _rolls[account][id];
    }

    function _rollDice(address sender, uint256 diceType) private {
        uint256 rollResult = 9; //TODO - Roll random value based on diceType
        _rolls[sender].push(rollResult);
        _rollCounts[msg.sender]++;
    }
}
