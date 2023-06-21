// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract TimelockDemo is ReentrancyGuard, Ownable {
   using SafeMath for uint256;
   
   address public contractOwner;
   uint256 public publicFee = 0.1 ether;
    
   struct Item {
        address tokenAddress;
        uint256 tokenAmount;
        uint256 unlockTime;
        bool withdrawn;
    }
   
   mapping (address => mapping(uint => Item)) public ownerLocks;
   Item[] public totalLocks;

    constructor () public {
      contractOwner = msg.sender;
  }

   modifier blockWithdraw() {
      require(block.timestamp >= 0, "You can't withdraw amount before 3 min.");
      _;
    } 

   modifier onlyContractOwner() {
      require(msg.sender == contractOwner, 'Only owner can call this function');
     _;
   }
   
   function lockTokens(
      address _tokenAddress,
      uint256 _amount,
      uint256 _unlockTime,
   ) external payable returns (uint256 _id) {
       require(_amount > 0, 'Tokens amount must be greater than 0.');
       require(_unlockTime < 10000000000, 'Unix timestamp must be in seconds, not milliseconds.');
       require(_unlockTime > block.timestamp, 'Unlock time must be in future.');
       require(msg.value > publicFee, 'BNB fee not provided'); 

       require(IERC20(_tokenAddress).approve(address(this), _amount), 'Failed to approve tokens.');
       require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount), 'Failed to transfer tokens to locker.'); 
      
       
      
       emit TokensLocked(_tokenAddress, msg.sender, _amount, _unlockTime, depositId);
   }
   
   function withdraw(address token, uint amount) external blockWithdraw {
     IERC20(token).transfer(contractOwner, amount);
   }
}