// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DiamondStorage.sol";

interface IDiamondCut {
    function diamondCut(address facet, bytes4[] calldata selectors) external;
}

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(address facet, bytes4[] calldata selectors) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.addReplaceFunctions(facet, selectors);
    }
}
