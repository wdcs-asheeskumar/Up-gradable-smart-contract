// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    mapping(bytes32 => uint256) public _uintStorage;
    uint256 public counter;

    function getUint(bytes32 key) public view returns (uint256) {
        return _uintStorage[key];
    }

    function setUint(bytes32 key, uint256 _id) public {
        _uintStorage[key] = _id;
    }

    function getIncrementCounter() public {
        counter++;
    }

    function getCounterValue() public view returns (uint256) {
        return counter;
    }
}

contract LogicContract {
    ProxyContract private _storage;

    constructor(address storageAddress) {
        _storage = ProxyContract(storageAddress);
    }

    function getCount() external view returns (uint256) {
        return _storage.getUint(keccak256(abi.encodePacked("count")));
    }

    function getCounter() external view returns (uint256) {
        return _storage.getCounterValue();
    }

    function increment() external {
        uint256 count = _storage.getUint(keccak256(abi.encodePacked("count")));
        _storage.setUint(keccak256(abi.encodePacked("count")), count + 1);
    }

    function decrement() external {
        // uint256 count = _storage.getUint(keccak256(abi.encodePacked("count")));
        _storage.getIncrementCounter();
    }
}
