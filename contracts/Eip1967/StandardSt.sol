pragma solidity ^0.8.0;

contract StorageManager {
    mapping(bytes32 => uint256) private _data;

    function setData(bytes32 key, uint256 value) external {
        _data[key] = value;
    }

    function getData(bytes32 key) external view returns (uint256) {
        return _data[key];
    }
}

contract MyContract {
    address private _storageManager;

    constructor(address storageManager) {
        _storageManager = storageManager;
    }

    function setData(bytes32 key, uint256 value) external {
        (bool success, ) = _storageManager.delegatecall(
            abi.encodeWithSignature("setData(bytes32,uint256)", key, value)
        );
        require(success, "Setting data failed");
    }

    function getData(bytes32 key) external view returns (uint256) {
        (bool success, bytes memory data) = _storageManager.staticcall(
            abi.encodeWithSignature("getData(bytes32)", key)
        );
        require(success, "Getting data failed");
        return abi.decode(data, (uint256));
    }
}
