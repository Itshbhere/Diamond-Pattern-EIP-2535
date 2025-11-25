// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CounterFacet {
    uint256 public count;

    function increment() external {
        count++;
    }

    function decrement() external {
        require(count > 0, "Count is zero");
        count--;
    }

    function getCount() external view returns (uint256) {
        return count;
    }
}
