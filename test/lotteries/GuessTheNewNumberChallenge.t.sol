// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GuessTheNewNumberChallenge} from "../../src/lotteries/challenges/GuessTheNewNumberChallenge.sol";
import {AttackGuessTheNewNumberChallenge} from "../../src/lotteries/helpers/AttackGuessTheNewNumberChallenge.sol";

contract TestGuessTheNewNumberChallenge is Test {
    GuessTheNewNumberChallenge challenge;
    AttackGuessTheNewNumberChallenge attack;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        challenge = new GuessTheNewNumberChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        // Deploy attack contract
        vm.startPrank(player);
        attack = new AttackGuessTheNewNumberChallenge(address(challenge));

        attack.attack{value: 1 ether}();
        vm.stopPrank();

        assert(player.balance == 2 ether);
        assert(challenge.isComplete());
    }
}
