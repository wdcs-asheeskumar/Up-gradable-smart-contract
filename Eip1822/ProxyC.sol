// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title UniversalUpgradableProxy
 * @dev This contract acts as a proxy that forwards all calls to a target contract.
 * It allows for upgrading the logic contract while preserving the proxy contract's address.
 */
contract UniversalUpgradableProxy {
    address private _currentLogicContract;

    /**
     * @dev Constructor function
     * @param initialLogicContract Address of the initial logic contract
     */
    constructor(address initialLogicContract) {
        _currentLogicContract = initialLogicContract;
    }

    /**
     * @dev Fallback function that forwards all calls to the current logic contract
     */
    fallback() external payable {
        _delegateCall(_currentLogicContract);
    }

    /**
     * @dev Function to upgrade the logic contract to a new contract
     * @param newLogicContract Address of the new logic contract
     */
    function upgradeLogicContract(address newLogicContract) external {
        _currentLogicContract = newLogicContract;
    }

    /**
     * @dev Internal function to delegate call to the logic contract
     * @param target Address of the logic contract to delegate call to
     */
    function _delegateCall(address target) private {
        assembly {
            // Get the location of the data being passed to this call
            let ptr := mload(0x40)

            // Copy input data (msg.data) to memory
            calldatacopy(ptr, 0, calldatasize())

            // Delegate call to the logic contract with the copied input data
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)

            // Get the size of the returned data
            let size := returndatasize()

            // Copy returned data to memory
            returndatacopy(ptr, 0, size)

            // Check if the call was successful
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
