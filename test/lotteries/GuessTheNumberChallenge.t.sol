// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GuessTheNumberChallenge} from "../../src/lotteries/GuessTheNumberChallenge.sol";

contract TestGuessTheNumberChallenge is Test {
    GuessTheNumberChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        challenge = new GuessTheNumberChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        vm.prank(player);
        challenge.guess{value: 1 ether}(42);

        assert(player.balance == 2 ether);
        assert(challenge.isComplete());
    }
}
