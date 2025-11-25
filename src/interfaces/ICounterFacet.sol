// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICounterFacet {
    function increment() external;
    function decrement() external;
    function getCount() external view returns (uint256);
}
