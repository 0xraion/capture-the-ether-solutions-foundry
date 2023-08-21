// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {RetirementFundChallenge} from "../../src/math/RetirementFundChallenge.sol";
import {AttackRetirementFund} from "../../src/math/AttackRetirementFund.sol";

contract TestRetirementFundChallenge is Test {
    RetirementFundChallenge challenge;
    AttackRetirementFund attack;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 0.01 ether);

        vm.prank(deployer);

        challenge = new RetirementFundChallenge{value: 1 ether}(player);
    }

    function test_Solution() external {
        vm.startPrank(player);
        attack = new AttackRetirementFund{value: 0.01 ether}(
            address(challenge)
        );

        challenge.collectPenalty();
        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
