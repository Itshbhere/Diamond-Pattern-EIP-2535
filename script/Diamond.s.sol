// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Diamond} from "../src/Diamond.sol";
import {CounterFacet} from "../src/Facet.sol";
import {DiamondCutFacet} from "../src/DiamondCut.sol";
import {IDiamondCut} from "../src/DiamondCut.sol";

contract DiamondScript is Script {
    function run() public {
        vm.startBroadcast();

        // 1. Deploy DiamondCutFacet
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();

        // 2. Deploy Diamond
        Diamond diamond = new Diamond(
            msg.sender, // owner
            address(diamondCutFacet) // the cut facet
        );

        // 3. Deploy CounterFacet
        CounterFacet counterFacet = new CounterFacet();

        // 4. Prepare selectors for CounterFacet
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = counterFacet.increment.selector;
        selectors[1] = counterFacet.decrement.selector;
        selectors[2] = counterFacet.getCount.selector;

        // 5. Call diamondCut to add the facet
        IDiamondCut(address(diamond)).diamondCut(address(counterFacet), selectors);

        vm.stopBroadcast();
    }
}
