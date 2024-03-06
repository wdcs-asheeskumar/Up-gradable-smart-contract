// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint256 public a;

    function setA(uint256 _a) public {
        a = _a;
    }
}

contract LogicContract {
    address public aAddress;
    uint256 public b;

    constructor(address _aAddress) {
        aAddress = _aAddress;
    }

    function setA(uint256 _a) public {
        (bool success, bytes memory result) = aAddress.delegatecall(
            abi.encodeWithSignature("setA(uint256)", _a)
        );
        require(success, "delegatecall failed");
    }

    function setB(uint256 _b) public {
        b = _b;
    }
}
