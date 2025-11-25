// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DiamondStorage.sol";
import {IDiamondCut} from "./DiamondCut.sol";

contract Diamond {
    constructor(address owner, address diamondCutFacet) {
        LibDiamond.setContractOwner(owner);

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = IDiamondCut.diamondCut.selector;

        LibDiamond.addReplaceFunctions(diamondCutFacet, selectors);
    }

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        LibDiamond.FacetAddressAndSelectorPosition memory f = ds.selectorToFacet[msg.sig];

        require(f.facetAddress != address(0), "Function not found");

        address facet = f.facetAddress;

        assembly {
            // copy call data
            calldatacopy(0, 0, calldatasize())
            // call the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // retrieve return data
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
