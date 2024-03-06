//SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

contract DiamondMessage {
    bytes32 internal constant NAMESPACE = keccak256("My_Namespace");

    struct MyMessage {
        string message;
    }

    function getMessage() public returns(string memory) {

    }

    function setMessage() public {

    }

    function getter() public {
        
    }
}