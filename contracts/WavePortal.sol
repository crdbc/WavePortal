// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    struct LinkDetail {
    address user;
    string linkText;
  }

  struct Wave {
    address waver;
    string message;
    uint256 timestamp;
  }

  event NewWave(address indexed from, uint256 timestamp, string message);

  LinkDetail[] public linkDetails;
  Wave[] waves;
  uint256 public linkCount;
  uint256 totalWaves;
  uint256 private seed;

  mapping(address =>  uint256) public lastWavedAt;

  constructor() payable {
    console.log("I AM A SMART CONTRACT. POG.");
    seed = (block.timestamp + block.difficulty) % 100;
  }

  function wave(string memory _message) public {

    require(lastWavedAt[msg.sender] + 15 seconds < block.timestamp, "Must wait 15 seconds beore waving again.");

    lastWavedAt[msg.sender] = block.timestamp;

    totalWaves += 1;
    console.log("%s waved w/ message %s", msg.sender, _message);

    waves.push(Wave(msg.sender, _message, block.timestamp));

    seed = (block.difficulty + block.timestamp + seed) % 100;
    console.log("Random # generated: %d:", seed);

    if(seed <= 50) {
      console.log("%s won!", msg.sender);

      uint256 prizeAmount = 0.0001 ether;
      require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");

      (bool success,) = (msg.sender).call{value: prizeAmount}("");
      require(success, "Failed to withdraw money from contract.");
    }

    emit NewWave(msg.sender, block.timestamp, _message);
  }

  function getAllWaves() public view returns (Wave[] memory){
    return waves;
  }

  function getTotalWaves() public view returns (uint256) {
    console.log("We have %d total waves!", totalWaves);

    return totalWaves;
  }

  function dropLink(string memory _link) public {

    linkDetails.push(LinkDetail(msg.sender, _link));

    linkCount++;

    console.log("New Link has been submitted", _link);
  }
}