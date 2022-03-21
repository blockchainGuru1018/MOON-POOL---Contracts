//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Room is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public token;
  address public winner;
  uint256 public roomId;
  address public receptionist;
  mapping(address => bool) withdrawn;

  struct RoomInfo {
    address player0;
    address player1;
    uint256 baseAmount;
    uint256 rate;
  }

  RoomInfo public info;
  bool public end;

  // constructor

  constructor (IERC20 _token, address _receptionist ) {
    token = _token;
    receptionist = _receptionist;
  }
  
  // init function
  function initRoom (
    address _player0,
    address _player1,
    uint256 _baseAmount,
    uint256 rate,
    uint256 _id
  ) external {
    require(msg.sender == receptionist, "Not Receptionist!");
    info.player0 = _player0;
    info.player1 = _player1;
    info.baseAmount = _baseAmount;
    info.rate = rate;
    roomId = _id;
  }

  // init again
  function formatRoom () external {
    require(msg.sender == receptionist, "Not Receptionist!");
    end = false;
    winner = address(0);
    withdrawn[info.player0] = false;
    withdrawn[info.player1] = false;
  }

  // decide winner
  function decideWinner (address _winner) external {
    require(msg.sender == receptionist, "Not Receptionist!");
    winner = _winner;
    end = true;
  }

  function withdraw () public {
    require(end, "Game is not over");
    require(!withdrawn[msg.sender], "You already withdrawn");
    if (msg.sender == winner) {
      uint256 amount = info.baseAmount.mul(2).mul(info.rate).div(100);
      withdrawn[msg.sender] = true;
      token.transfer(msg.sender, amount);
    } else {
      uint256 amount = info.baseAmount.mul(2).mul(100 - info.rate).div(100);
      withdrawn[msg.sender] = true;
      token.transfer(msg.sender, amount);
    }
  }

  function baseAmount() external view returns (uint256) {
    return info.baseAmount;
  }

  function player0() external view returns (address) {
    return info.player0;
  }

  function player1() external view returns (address) {
    return info.player1;
  }
}