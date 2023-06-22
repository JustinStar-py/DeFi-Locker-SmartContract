// SPDX-License-Identifier: MIT-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {
  IERC20 public token;
  uint256 public depositDeadline;
  uint256 public lockDuration;

  constructor() ERC20("Demo Token", "DET") {
        _mint(msg.sender, 1000 * 10 ** 18);
  }
}