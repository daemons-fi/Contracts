//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DAEM Vesting Contract
 * @dev Contract used to linearly vest tokens for multiple beneficiaries.
 * How to use:
 * Step 1: deploy the contract, defining the address of the token to be vested, a start date and a duration
 * Step 2: transfer the total amount of tokens to be vested to the Vesting contract
 * Step 3: Define beneficiaries and relative amounts they are due
 *
 * If after the start date some tokens are unassigned, the owner can claim them back
 * Anyone can release the due amount, by calling the release function and specifying the beneficiary address
 */
contract Vesting is Ownable {
    IERC20 public immutable token;
    uint256 public immutable start;
    uint256 public immutable duration;

    uint256 public allocated;
    mapping(address => uint256) public totalBalance;
    mapping(address => uint256) public released;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        ERC20 _token,
        uint256 _start,
        uint256 _duration
    ) {
        require(address(_token) != address(0));

        token = _token;
        duration = _duration;
        start = _start;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Adds a beneficiary for the vesting and the amount of tokens that belong to it
    /// @param beneficiary the address that will be able to withdraw the tokens after the vesting period
    /// @param amount the amount of tokens the beneficiary will be able to withdraw
    function addBeneficiary(address beneficiary, uint256 amount) external onlyOwner {
        require(block.timestamp < start, "Vesting started. Modifications forbidden");
        require(totalBalance[beneficiary] == 0, "Beneficiary is already in use");
        require(
            amount <= token.balanceOf(address(this)) - allocated,
            "Amount is higher than available for vesting"
        );

        allocated += amount;
        totalBalance[beneficiary] = amount;
    }

    /// @notice Send back to the owner the unallocated tokens
    /// @dev to call this function, the vesting period must have started
    function claimUnallocatedTokens() external onlyOwner {
        require(block.timestamp > start, "Vesting has not started yet");
        uint256 unallocated = token.balanceOf(address(this)) - allocated;
        require(unallocated > 0, "All tokens have been allocated");
        token.transfer(msg.sender, unallocated);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /// @notice Sends the due amount of tokens to the specified beneficiary
    /// @param beneficiary the address that will receive its due part
    function release(address beneficiary) external {
        uint256 unreleased = releasableAmount(beneficiary);
        require(unreleased > 0, "Nothing to release");

        released[beneficiary] += unreleased;
        token.transfer(beneficiary, unreleased);
    }

    /* ========== VIEWS FUNCTIONS ========== */

    /// @notice The amount of tokens that have not been assigned to any beneficiary
    function unallocatedTokens() public view returns (uint256) {
        return token.balanceOf(address(this)) - allocated;
    }

    /// @notice The amount a beneficiary can release in this moment
    /// @param beneficiary the address to check
    function releasableAmount(address beneficiary) public view returns (uint256) {
        return vestedAmount(beneficiary) - released[beneficiary];
    }

    /// @notice The amount of tokens that have been vested for a beneficiary
    /// @param beneficiary the address to check
    function vestedAmount(address beneficiary) public view returns (uint256) {
        if (block.timestamp < start) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return totalBalance[beneficiary];
        } else {
            return (totalBalance[beneficiary] * (block.timestamp - start)) / duration;
        }
    }
}
