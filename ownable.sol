// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

  
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
  
    function owner() public view returns(address) {
        return _owner;

    }


}