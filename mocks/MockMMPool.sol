// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "../interfaces/IMoneyMarket.sol";
import "./MockToken.sol";

contract MockMoneyMarketPool is IMoneyMarket {
    MockToken private token;
    MockToken private aToken;
    MockToken private debtToken;

    constructor(
        address _token,
        address _aToken,
        address _debtToken
    ) {
        token = MockToken(_token);
        aToken = MockToken(_aToken);
        debtToken = MockToken(_debtToken);
    }

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16
    ) external override {
        require(asset == address(token), "Always specify token, not aToken");

        // get tokens from the executor
        token.transferFrom(msg.sender, address(this), amount);

        // burn them, for simplicity
        token.burn(amount);

        // mint aTokens into the user's address
        aToken.mint(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(asset == address(token), "Always specify token, not aToken");

        // burn message sender aTokens
        aToken.justBurn(msg.sender, amount);

        // mint tokens into the user's address
        token.mint(to, amount);

        return 0;
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256,
        uint16,
        address onBehalfOf
    ) external override {
        require(asset == address(token), "Always specify token, not aToken");

        // mint tokens into the **SENDER** address
        token.mint(msg.sender, amount);

        // mint debt tokens into the **USER** address
        debtToken.mint(onBehalfOf, amount);
    }

    function repay(
        address asset,
        uint256 amount,
        uint256,
        address onBehalfOf
    ) external override returns (uint256) {
        require(asset == address(token), "Always specify token, not aToken");

        // the amount paid is MIN(amount, debt)
        uint256 debt = debtToken.balanceOf(onBehalfOf);
        debt = debt < amount ? debt : amount;

        // get tokens from the executor
        token.transferFrom(msg.sender, address(this), debt);

        // burn them, for simplicity
        token.burn(debt);

        // burn the debtTokens as well
        debtToken.justBurn(onBehalfOf, debt);

        // the final amount repaid is returned
        return debt;
    }

    function getUserAccountData(address)
        external
        pure
        override
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return (0, 0, 35e18, 0, 0, 2e18);
    }
}
