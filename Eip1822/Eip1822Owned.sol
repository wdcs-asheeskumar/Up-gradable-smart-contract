//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./Proxiable.sol";
contract Owned is Proxiable {
    // ensures no one can manipulate this contract once it is deployed
    address public owner = address(1);

    function constructor1() public{
        // ensures this can be called only once per *proxy* contract deployed
        require(owner == address(0));
        owner = msg.sender;
    }

    function updateCode(address newCode) onlyOwner public {
        updateCodeAddress(newCode);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed to perform this action");
        _;
    }
}