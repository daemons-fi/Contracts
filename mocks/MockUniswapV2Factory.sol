// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "./MockToken.sol";

contract MockUniswapV2Factory is IUniswapV2Factory {
    mapping(address => mapping(address => address)) pairs;

    function setFakePair(
        address tokenA,
        address tokenB,
        address pair
    ) external {
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
    }

    function feeTo() external pure override returns (address) {
        require(1 == 2, "'feeTo' has not been implemented");
        return address(0);
    }

    function feeToSetter() external pure override returns (address) {
        require(1 == 2, "'feeToSetter' has not been implemented");
        return address(0);
    }

    function migrator() external pure override returns (address) {
        require(1 == 2, "'migrator' has not been implemented");
        return address(0);
    }

    function getPair(address tokenA, address tokenB) external view override returns (address pair) {
        address lpAddress = pairs[tokenA][tokenB];
        if (lpAddress == address(0)) {
            console.log("The LP was not found, but we'll let the executor deal with it.");
        }
        return lpAddress;
    }

    function allPairs(uint256) external pure override returns (address pair) {
        require(1 == 2, "'allPairs' has not been implemented");
        return address(0);
    }

    function allPairsLength() external pure override returns (uint256) {
        require(1 == 2, "'allPairsLength' has not been implemented");
        return 0;
    }

    function createPair(address, address) external pure override returns (address) {
        require(1 == 2, "'createPair' has not been implemented");
        return (address(0));
    }

    function setFeeTo(address) external override {}

    function setFeeToSetter(address) external override {}

    function setMigrator(address) external override {}
}
