//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IRoom {
  function decideWinner (address _winner) external;
  function baseAmount () external view returns (uint256);
  function player0() external view returns (address);
  function player1() external view returns (address);
  function formatRoom() external;
}