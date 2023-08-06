// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {TokenWhaleChallenge} from "../../src/math/TokenWhaleChallenge.sol";

contract TestTokenWhaleChallenge is Test {
    TokenWhaleChallenge challenge;

    address deployer;
    address user;
    address user2;

    function setUp() external {
        deployer = address(1);
        user = address(2);
        user2 = address(3);

        vm.prank(deployer);
        challenge = new TokenWhaleChallenge(user);
    }

    function testIsComplete() external {
        vm.prank(user);
        challenge.transfer(user2, 501);

        assertEq(challenge.balanceOf(user), 499);
        assertEq(challenge.balanceOf(user2), 501);
        
        vm.prank(user2);
        challenge.approve(user, 500);

        vm.prank(user);
        challenge.transferFrom(user2, user2, 500);

        assert(challenge.isComplete());
    }
}