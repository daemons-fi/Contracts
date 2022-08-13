// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IMoneyMarket.sol";
import "./MockMMPool.sol";

contract MockReserveDataV2 is MockMoneyMarketPool, IGetReserveDataV2 {
    constructor(
        address _token,
        address _aToken,
        address _debtToken
    ) MockMoneyMarketPool(_token, _aToken, _debtToken) {}

    function getReserveData(address) external pure returns (IGetReserveDataV2.ReserveData memory) {
        return
            IGetReserveDataV2.ReserveData(
                ReserveConfigurationMap(0),
                0,
                0,
                123, // supply APY RAY
                456, // variable borrow APY RAY
                789, // fixed borrow APY RAY
                0,
                address(0),
                address(0),
                address(0),
                address(0),
                0
            );
    }
}

contract MockReserveDataV3 is MockMoneyMarketPool, IGetReserveDataV3 {
    constructor(
        address _token,
        address _aToken,
        address _debtToken
    ) MockMoneyMarketPool(_token, _aToken, _debtToken) {}

    function getReserveData(address) external pure returns (IGetReserveDataV3.ReserveData memory) {
        return
            IGetReserveDataV3.ReserveData(
                ReserveConfigurationMap(0),
                0,
                123, // supply APY RAY
                0,
                456, // variable borrow APY RAY
                789, // fixed borrow APY RAY
                0,
                0,
                address(0),
                address(0),
                address(0),
                address(0),
                0,
                0,
                0
            );
    }
}
