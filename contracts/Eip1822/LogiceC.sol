// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Counter
 * @dev Simple contract to demonstrate EIP-1822 Universal Upgradable Proxy
 */
contract Counter {
    uint256 private _count;

    /**
     * @dev Event emitted when the count is incremented
     * @param newValue New value of the count
     */
    event CountIncremented(uint256 newValue);

    /**
     * @dev Constructor function
     * @param initialValue Initial value of the count
     */
    constructor(uint256 initialValue) {
        _count = initialValue;
    }

    /**
     * @dev Function to get the current count value
     * @return Current value of the count
     */
    function getCount() external view returns (uint256) {
        return _count;
    }

    /**
     * @dev Function to increment the count value
     */
    function incrementCount() external {
        _count++;
        emit CountIncremented(_count);
    }
}
