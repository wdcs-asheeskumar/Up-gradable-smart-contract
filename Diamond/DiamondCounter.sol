//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract DiamondCounter {
    uint256 private i;
    bytes4 public functionSelector;
    constructor() {
        functionSelector = bytes4(keccak256("increment"));
    }
    function increment() public {
        i++;
    }

    function get() public view returns (uint256) {
        return i;
    }
     
}

contract Diamond {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    struct FacetCut {
        address facetAddress;
        bytes4 functionSelectors;
    }

    struct FacetAddressAndPosition {
        address facetAddress;
        uint256 functionSelectorPosition;
    }

    struct FacetFunctionSelectors {
        bytes4 functionSelectors;
        uint256 facetAddressPosition;
    }
    uint256 public id;

    function diamondCut(bytes4 _bytes, address _address) public {
        require(
            diamondStorage().selectorToFacetAndPosition[_bytes].facetAddress ==
                address(0),
            "facet already added"
        );
        id = id + 1;
        FacetCut memory newFacetCut;
        FacetAddressAndPosition memory newFacetAddressAndPosition;
        FacetFunctionSelectors memory newFacetFunctionSelectors;
        newFacetCut.facetAddress = _address;
        newFacetCut.functionSelectors = _bytes;
        newFacetAddressAndPosition.facetAddress = _address;
        newFacetAddressAndPosition.functionSelectorPosition = id;
        newFacetFunctionSelectors.functionSelectors = _bytes;
        newFacetFunctionSelectors.facetAddressPosition = id;
        diamondStorage().selectorToFacetAndPosition[_bytes] = newFacetAddressAndPosition;
        diamondStorage().facetFunctionSelectors[_address] = newFacetFunctionSelectors;
        diamondStorage().facetAddresses.push(_address);
        diamondStorage().contractOwner = msg.sender;
    }
    
    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        address contractOwner;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    fallback() external payable {
        address facet = diamondStorage().selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond doesn't exist");

        assembly {
            calldatacopy(0,0,calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result 
            case 0 {
                revert (0, returndatasize())
            } default {
                return (0, returndatasize())
            }
        }
     }
    receive() external payable { }
}
