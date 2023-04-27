// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.3/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {
  IERC20 public token;
  uint256 public depositDeadline;
  uint256 public lockDuration;

  constructor() ERC20("Timelock Token Demo", "TTD") {
        _mint(msg.sender, 1000000 * 10 ** 18);
  }
}

contract TimelockDemo {

  uint public constant lockDuration = 60*3;
  uint public immutable endLocking;
  address public immutable owner;

  constructor() {
    owner = msg.sender;
    endLocking = block.timestamp + lockDuration;
  }

  modifier blockWithdraw() {
    require(block.timestamp >= endLocking, "You can't withdraw amount before 3 min.");
    _;
  } 

  function withdraw(address token, uint amount) external blockWithdraw {
    IERC20(token).transfer(owner, amount);
  }
}