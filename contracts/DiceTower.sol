// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DiceTower {
    address payable creatorWallet;
    IERC20 private _d20TokenContractAddress;

    mapping(address => uint256[]) private _rolls;
    mapping(address => uint256) private _rollCounts;

    uint256 randNonce;

    constructor() {
        creatorWallet = payable(msg.sender);
    }

    event Rolled(
        address indexed _sender,
        uint256 indexed _diceType,
        uint256 _rollIndex,
        uint256 rollResult
    );

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
        _d20TokenContractAddress.approve(msg.sender, 1000000000000000000);
        require(
            _d20TokenContractAddress.allowance(address(this), msg.sender) > 0,
            "allowance"
        );
        _rollDice(msg.sender, 20);
        _d20TokenContractAddress.transfer(msg.sender, 1000000000000000000);
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
        uint256 rollResult = random(1, diceType);
        uint256 rollIndex = _rollCounts[msg.sender];
        _rolls[sender].push(rollResult);
        _rollCounts[msg.sender]++;
        emit Rolled(sender, diceType, rollIndex, rollResult);
    }

    function random(uint256 min, uint256 max) internal returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))
        ) % (max - min);
        randomnumber = randomnumber + min;
        randNonce++;
        return randomnumber;
    }
}
