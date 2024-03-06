// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for delegate contract
interface Delegate {
    function getValue() external view returns (uint);
    function setValue(uint _value) external;
}

// Delegate contract
contract MyDelegate is Delegate {
    uint private value;

    function getValue() external view override returns (uint) {
        return value;
    }

    function setValue(uint _value) external override {
        value = _value;
    }
}

// Owner contract
contract Owner {
    address public delegate;
    uint public ownerValue;

    constructor(address _delegate) {
        delegate = _delegate;
    }

    // Function to get value from delegate contract
    function getDelegateValue() public view returns (uint) {
        Delegate _delegate = Delegate(delegate);
        return _delegate.getValue();
    }

    // Function to set value in delegate contract
    function setDelegateValue(uint _value) public {
        Delegate _delegate = Delegate(delegate);
        _delegate.setValue(_value);
    }

    // Function to set value in owner contract
    function setOwnerValue(uint _value) public {
        ownerValue = _value;
    }
}
