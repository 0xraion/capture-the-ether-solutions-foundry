// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GuessTheNumberChallenge} from "../../src/lotteries/GuessTheNumberChallenge.sol";

contract TestGuessTheNumberChallenge is Test {
    GuessTheNumberChallenge challenge;

    address deployer;
    address user;

    function setUp() external {
        deployer = address(1);
        user = address(2);

        vm.deal(deployer, 1 ether);
        vm.deal(user, 1 ether);

        vm.prank(deployer);
        challenge = new GuessTheNumberChallenge{value: 1 ether}();
    }

    function testIsComplete() external {
        vm.prank(user);
        challenge.guess{value: 1 ether}(42);

        assertEq(user.balance, 2 ether);
        assert(challenge.isComplete());
    }
}
