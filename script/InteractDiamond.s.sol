// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ICounterFacet} from "../src/interfaces/ICounterFacet.sol";

contract InteractDiamondScript is Script {
    function run() public {
        // Get Diamond address from environment variable or use default
        address diamondAddress = address(0xAACe86cAFFDc7508523F0a9eAaB1a3b5423e1DDF);
        require(diamondAddress != address(0), "DIAMOND_ADDRESS not set");

        vm.startBroadcast();

        // Cast Diamond address to CounterFacet interface to call its functions
        ICounterFacet diamond = ICounterFacet(diamondAddress);

        console.log("=== Interacting with Diamond at:", diamondAddress);
        console.log("");

        // Get initial count
        uint256 initialCount = diamond.getCount();
        console.log("Initial count:", initialCount);
        console.log("");

        // Increment the counter
        console.log("Calling increment()...");
        diamond.increment();
        uint256 afterIncrement = diamond.getCount();
        console.log("Count after increment:", afterIncrement);
        console.log("");

        // Increment again
        console.log("Calling increment() again...");
        diamond.increment();
        uint256 afterSecondIncrement = diamond.getCount();
        console.log("Count after second increment:", afterSecondIncrement);
        console.log("");

        // Decrement the counter
        console.log("Calling decrement()...");
        diamond.decrement();
        uint256 afterDecrement = diamond.getCount();
        console.log("Count after decrement:", afterDecrement);
        console.log("");

        // Final count
        uint256 finalCount = diamond.getCount();
        console.log("Final count:", finalCount);

        vm.stopBroadcast();
    }
}
