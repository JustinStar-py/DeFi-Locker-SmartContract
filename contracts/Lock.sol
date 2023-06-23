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
    uint256 public publicFee = 1 ether;

    struct Item {
        address lockOwner;
        address tokenAddress;
        uint256 tokenAmount;
        uint256 unlockTime;
        bool withdrawn;
    }

    mapping (address => Item[]) public ownerLocks;
    Item[] public totalLocks;

    constructor () {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, 'Only owner can call this function');
        _;
    }

    function lockTokens(
        address _lpToken,
        uint256 _lpAmount,
        uint256 _unlockTime
    ) external payable returns (uint256 _id) {
        require(_lpAmount > 0, "LP tokens amount must be greater than 0.");
        require(_unlockTime < 10000000000, 'Unix timestamp must be in seconds, not milliseconds.');
        require(_unlockTime > block.timestamp, 'Unlock time must be in future.');
        require(msg.value >= publicFee, 'ETH fee not provided');

         IERC20 lpToken = IERC20(_lpToken);
        require(lpToken.transferFrom(msg.sender, address(this), _lpAmount), "Failed to transfer LP tokens.");

        uint256 fee = msg.value;
        payTo(owner(), fee);

        uint256 id = totalLocks.length;
        Item memory lock = Item(msg.sender, _lpToken, _lpAmount, _unlockTime, false);
        ownerLocks[msg.sender].push(lock);
        totalLocks.push(lock);

        return id;
    }

    function withdraw(uint256 _id) external {
        require(ownerLocks[msg.sender].length > 0, "You haven't made any lock.");
        require(_id < totalLocks.length, "Invalid lock ID.");

        Item storage lock = totalLocks[_id];
        require(lock.lockOwner == msg.sender, "You are not the owner of this lock.");
        require(!lock.withdrawn, "Tokens have already been withdrawn.");
        require(lock.unlockTime <= block.timestamp, "Tokens are still locked.");

        IERC20 lpToken = IERC20(lock.lpToken);
        require(lpToken.transfer(msg.sender, lock.lpAmount), "Failed to transfer LP tokens.");
        
        lock.withdrawn = true;
    }

    function payTo(address _to, uint256 _amount) internal returns (bool) {
       (bool success,) = payable(_to).call{value: _amount}("");
       require(success, "Payment failed");
       return true;
   }
}