// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLock {
  ERC20 public token;
  uint256 public depositDeadline;
  uint256 public lockDuration;

  /// Withdraw amount exceeds sender's balance of the locked token
  error ExceedsBalance();
  /// Deposit is not possible anymore because the deposit period is over
  error DepositPeriodOver();
  /// Withdraw is not possible because the lock period is not over yet
  error LockPeriodOngoing();
  /// Could not transfer the designated ERC20 token
  error TransferFailed();
  /// ERC-20 function is not supported
  error NotSupported();

  struct lockInfo {
    address _owner;
    address _token;
    uint256 _depositDeadline;
    uint256 _lockDuration;
    string _name;
    string _symbol;
  }

  /// @dev Deposit tokens to be locked until the end of the locking period
  /// @param amount The amount of tokens to deposit
  function deposit(uint256 amount) public {
    if (block.timestamp > depositDeadline) {
      revert DepositPeriodOver();
    }

    require(token.transferFrom(msg.sender, address(this), amount), "transferFailed");
  }

  /// @dev Withdraw tokens after the end of the locking period or during the deposit period
  /// @param amount The amount of tokens to withdraw
  function withdraw(uint256 amount) public {
    if (
      block.timestamp > depositDeadline &&
      block.timestamp < depositDeadline + lockDuration
    ) {
      revert LockPeriodOngoing();
    }
    // if (balanceOf[msg.sender] < amount) {
    //   revert ExceedsBalance();
    // }

    if (!token.transfer(msg.sender, amount)) {
      revert TransferFailed();
    }

  }

}