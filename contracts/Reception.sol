//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Room.sol";
import "./IRoom.sol";

contract Reception is Ownable {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;

  event RoomCreated(uint256 roomId);

  struct Reserve {
    address player0;
    address player1;
    uint256 baseAmount;
    uint256 jointCount;
    uint256 startTime;
  }

  EnumerableSet.AddressSet private rooms;

  address public devAddr;
  IERC20 public token;
  uint256 public winnerRate = 80;
  uint256 public devFee;
  uint256 public depositTime = 5 minutes;

  constructor(
    address _devAddr,
    address _token
  ) {
    devAddr = _devAddr;
    token = IERC20(_token);
  }

  // owner function
  function setWinnerRate (uint256 _rate) public onlyOwner {
    require(_rate > 50, "Wrong rate!");
    winnerRate = _rate;
  }

  function setDevFee (uint256 _fee) public onlyOwner {
    devFee = _fee;
  }

  function setDepositTime (uint256 _depositTime) public onlyOwner {
    depositTime = _depositTime;
  }

  // user deposit
  function userDeposit(uint256 _roomId) public {
    IRoom _room = IRoom(rooms.at(_roomId));
    uint256 realBaseAmount = _room.baseAmount();
    if(devFee > 0) {
      realBaseAmount -= devFee;
      token.transferFrom(msg.sender, devAddr, devFee);
    }
    // deposit token;
    token.transferFrom(msg.sender, address(_room), realBaseAmount);
  }

  // rejoin
  function rejoin(uint256 _roomId) public {
    IRoom _room = IRoom(rooms.at(_roomId));
    require(token.balanceOf(msg.sender) >= _room.baseAmount(), "Insufficient Balance");
    require(msg.sender == _room.player0() || msg.sender == _room.player1(), "Invalid Player");
    if(devFee > 0) {
      require(token.transferFrom(msg.sender, devAddr, devFee), "Pay Fee: failed!");
    }
    require(token.transferFrom(msg.sender, address(_room), _room.baseAmount()), "can't deposit tokens");
    _room.formatRoom();
  }

  // room function
  function roomsLength () external view returns (uint256) {
    return rooms.length();
  }
  
  function roomAtIndex (uint256 _index) external view returns (address) {
    return rooms.at(_index);
  }

  // call by challenger
  function createRoom (address player0, address player1, uint256 baseAmount) public {
    Room newRoom = new Room(token, address(this));
    // roomid
    uint256 roomId = rooms.length();
    // register room
    rooms.add(address(newRoom));
    // init room
    newRoom.initRoom(
      player0, 
      player1, 
      baseAmount,
      winnerRate,
      roomId
    );
    emit RoomCreated(roomId);
  }

  // decide winner
  function decideWinner (uint256 _index, address _winner) public onlyOwner {
    address _room = rooms.at(_index);
    IRoom(_room).decideWinner(_winner);
  }
}