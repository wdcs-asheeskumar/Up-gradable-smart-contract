//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MessageFacet {
    bytes32 internal constant NAMESPACE = keccak256("message.faucet");

    struct Storage {
        string message;
    }

    function getStorage() internal pure returns(Storage storage s){
        bytes32 position = NAMESPACE;
        assembly {
            s.slot := position
        }
    }

    function setStorage(string calldata _msg) external {
        Storage storage s = getStorage();
        s.message = _msg;
    } 

    function getter() external returns(string memory) {
        return getStorage().message;
    }
}