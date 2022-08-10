// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IAavePriceOracleGetter.sol";

contract MockPriceOracleGetter is IPriceOracleGetter {
    uint256 fakePrice;

    constructor(uint256 _fakePrice) {
        fakePrice = _fakePrice;
    }

    /// @inheritdoc IPriceOracleGetter
    function getAssetPrice(address) external override view returns (uint256) {
        return fakePrice;
    }
}
