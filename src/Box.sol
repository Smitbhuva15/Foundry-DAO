// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    constructor(address owner) Ownable(owner) {}

    uint256 private number;
    event NumberChanged(uint256 newNumber);

    function store(uint256 num) public onlyOwner {
        number = num;
        emit NumberChanged(num);
    }

    function getNumber() external view returns (uint256) {
        return number;
    }

}