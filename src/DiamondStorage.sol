// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        // selector => facet address
        mapping(bytes4 => FacetAddressAndSelectorPosition) selectorToFacet;
        // all function selectors
        bytes4[] selectors;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 pos = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := pos
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DiamondCut(bytes4[] selectors, address indexed facetAddress);

    function setContractOwner(address newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
    }

    function addReplaceFunctions(address facet, bytes4[] memory selectors) internal {
        require(facet != address(0), "Invalid facet");

        DiamondStorage storage ds = diamondStorage();

        for (uint256 i; i < selectors.length; i++) {
            bytes4 selector = selectors[i];
            ds.selectorToFacet[selector] =
                FacetAddressAndSelectorPosition({facetAddress: facet, selectorPosition: uint16(ds.selectors.length)});
            ds.selectors.push(selector);
        }

        emit DiamondCut(selectors, facet);
    }
}
