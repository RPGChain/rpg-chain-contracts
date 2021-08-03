// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPFarm is Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct Account {
        uint256 lpDeposited;
        uint256 rewardPending;
        uint256 rewardDebt;
    }

    uint256 public lastRewardTime;
    uint256 public accumulatedRewardPerShare;

    IERC20 public immutable rewardToken;
    IERC20 public immutable lpToken;

    uint256 public rewardPerSecond;

    uint32 public immutable startTime;
    uint32 public endTime;

    mapping(address => Account) public accounts;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        address _rewardToken,
        address _lpToken,
        uint256 _rewardPerSecond,
        uint32 _startTime
    ) {
        require(
            _rewardToken != address(0) && _lpToken != address(0),
            "Invalid constructor parameters"
        );
        rewardToken = IERC20(_rewardToken);
        lpToken = IERC20(_lpToken);
        rewardPerSecond = _rewardPerSecond;
        startTime = _startTime;
        endTime = _startTime + 7 days;
    }

    function changeEndTime(uint32 addSeconds) external onlyOwner {
        endTime += addSeconds;
    }

    function rewardPending(address _accountAddress)
        external
        view
        returns (uint256 rewardPendingValue)
    {
        Account storage account = accounts[_accountAddress];
        uint256 accumulatedRewardPerShareTemp = accumulatedRewardPerShare;
        uint256 lpSupply = lpToken.balanceOf(address(this));
        if (block.timestamp > lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(lastRewardTime, block.timestamp);
            uint256 pTokenReward = multiplier * rewardPerSecond;
            accumulatedRewardPerShareTemp += (pTokenReward * 1e12) / lpSupply;
        }
        rewardPendingValue =
            (account.lpDeposited * accumulatedRewardPerShareTemp) /
            1e12 -
            account.rewardDebt +
            account.rewardPending;
    }

    function setRewardPerSecond(uint256 _rewardPerSecond, bool _withUpdate)
        external
        onlyOwner
    {
        if (_withUpdate) {
            updatePool();
        }
        rewardPerSecond = _rewardPerSecond;
    }

    function updatePool() internal {
        if (block.timestamp <= lastRewardTime) {
            return;
        }
        uint256 lpSupply = lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(lastRewardTime, block.timestamp);

        uint256 pTokenReward = multiplier * rewardPerSecond;
        accumulatedRewardPerShare += (pTokenReward * 1e12) / lpSupply;

        lastRewardTime = block.timestamp;
    }

    function deposit(uint256 _amount) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        updatePool();
        if (account.lpDeposited > 0) {
            uint256 rewardPendingValue = (account.lpDeposited *
                accumulatedRewardPerShare) /
                1e12 -
                account.rewardDebt +
                account.rewardPending;
            account.rewardPending = safeRewardTransfer(
                rewardToken,
                msg.sender,
                rewardPendingValue
            );
        }
        lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        account.lpDeposited += _amount;
        account.rewardDebt =
            (account.lpDeposited * accumulatedRewardPerShare) /
            1e12;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public whenNotPaused {
        Account storage account = accounts[msg.sender];
        require(account.lpDeposited >= _amount, "withdraw failed");
        updatePool();
        uint256 rewardPendingValue = (account.lpDeposited *
            accumulatedRewardPerShare) /
            1e12 -
            account.rewardDebt +
            account.rewardPending;
        account.rewardPending = safeRewardTransfer(
            rewardToken,
            msg.sender,
            rewardPendingValue
        );
        account.lpDeposited -= _amount;
        account.rewardDebt =
            (account.lpDeposited * accumulatedRewardPerShare) /
            1e12;
        lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    // Return reward multiplier over the given _from to _to time.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        _from = _from > startTime ? _from : startTime;
        if (_from > endTime || _to < startTime) {
            return 0;
        }
        if (_to > endTime) {
            return endTime - _from;
        }
        return _to - _from;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        Account storage account = accounts[msg.sender];
        uint256 accountAmount = account.lpDeposited;
        delete accounts[msg.sender];
        lpToken.safeTransfer(address(msg.sender), accountAmount);
        emit EmergencyWithdraw(msg.sender, accountAmount);
    }

    // Safe transfer function, in case pool does not have enough reward tokens.
    function safeRewardTransfer(
        IERC20 rewardTokenToSend,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        uint256 rewardTokenBalance = rewardTokenToSend.balanceOf(address(this));
        if (rewardTokenBalance == 0) {
            //save some gas fee
            return _amount;
        }
        if (_amount > rewardTokenBalance) {
            //save some gas fee
            rewardTokenToSend.transfer(_to, rewardTokenBalance);
            return _amount - rewardTokenBalance;
        }
        rewardTokenToSend.transfer(_to, _amount);
        return 0;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
