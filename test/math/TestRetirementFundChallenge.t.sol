// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {RetirementFundChallenge} from "../../src/math/RetirementFundChallenge.sol";
import {AttackRetirementFund} from "../../src/math/AttackRetirementFund.sol";

contract TestRetirementFundChallenge is Test {
    RetirementFundChallenge challenge;
    AttackRetirementFund attack;
    address deployer;
    address user;

    function setUp() external {
        deployer = address(1);
        user = address(2);

        vm.deal(deployer, 1 ether);
        vm.deal(user, 0.01 ether);
        vm.prank(deployer);

        challenge = new RetirementFundChallenge{value: 1 ether}(user);
    }

    function testAttack() external {
        vm.startPrank(user);
        attack = new AttackRetirementFund{value: 0.01 ether}(address(challenge));

        challenge.collectPenalty();
        vm.stopPrank();
        
        assert(challenge.isComplete());
    }
}