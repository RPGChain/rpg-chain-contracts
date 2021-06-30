// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Oracle {
    address admin;
    uint256 public rand;

    constructor() public {
        admin = msg.sender;
    }

    function feedRandomness(uint256 _rand) external {
        require(msg.sender == admin);
        rand = _rand;
    }
}

contract D20Token is ERC20, ERC20Burnable {
    // Maximum total supply of the token (20M)
    uint256 private _maxTotalSupply = 20000000000000000000000000;
    // Store rolls
    mapping(address => Roll[]) private _rolls;
    // Oracle for randomness
    Oracle oracle;
    uint256 nonce;

    struct Roll {
        uint256 result;
        address recipient;
    }

    constructor() ERC20("D20Token", "D20") {
        oracle = Oracle();
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

    receive() external payable {
        // Check if sending to the contract address, if so, send back
        // At least make method to send back like HRO roken
        //roll(_msgSender(), _msgSender()); // TODO - sender->recipient
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        roll(_msgSender(), recipient);
        return true;
    }

    function roll(address sender, address recipient) private {
        //DiceTower diceTower;
        //uint256 nonce;
        //_rolls[sender].push(Roll(10, recipient));
        uint256 rand = _randModulus(10);
        _rolls[sender].push(Roll(rand, recipient));
    }

    // Show the number of rolls from an account
    function rollsCountFrom(address account) public view returns (uint256) {
        return _rolls[account].length;
    }

    // Show the number of rolls from an account and recipient
    function rollsCountFromTo(address account, address recipient)
        public
        view
        returns (uint256)
    {
        uint256 rollsCount = 0;
        for (uint256 i = 0; i < _rolls[account].length; i++) {
            if (_rolls[account][i].recipient == recipient) {
                rollsCount++;
            }
        }
        return rollsCount;
    }

    // Show the roll result account at index
    function rollsResultFrom(address account, uint256 index)
        public
        view
        returns (uint256)
    {
        return _rolls[account][index].result;
    }

    // Show the roll result from an account and recipient at index
    function rollsResultFromTo(
        address account,
        address recipient,
        uint256 index
    ) public view returns (uint256) {
        uint256 rollsCount = 0;

        for (uint256 i = 0; i < _rolls[account].length; i++) {
            if (_rolls[account][i].recipient == recipient) {
                if (rollsCount == index) {
                    return _rolls[account][i].result;
                } else {
                    rollsCount++;
                }
            }
        }
        return 0;
    }

    function _randModulus(uint256 mod) internal returns (uint256) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    nonce,
                    oracle.rand(),
                    now,
                    block.difficulty,
                    msg.sender
                )
            )
        ) % mod;
        nonce++;
        return rand;
    }
}
