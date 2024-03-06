//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract EipProxyContract {
    address currentLogicContract;

    constructor(address _currentLogicContract) {
       currentLogicContract = _currentLogicContract;
    }

    fallback() external payable {
        delegatecall(currentLogicContract);
    }

    function delegatecall(address target) public {
        assembly {
            let ptr := mload(0x40)
        }
    }
}
