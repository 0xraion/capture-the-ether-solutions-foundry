// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GuessTheNewNumberChallenge} from "../../src/lotteries/GuessTheNewNumberChallenge.sol";
import {AttackGuessTheNewNumberChallenge} from "../../src/lotteries/AttackGuessTheNewNumberChallenge.sol";

contract TestGuessTheNewNumberChallenge is Test {
    GuessTheNewNumberChallenge challenge;
    AttackGuessTheNewNumberChallenge attack;

    address deployer;
    address attacker;

    function setUp() external {
        deployer = address(1);
        attacker = address(2);

        vm.deal(deployer, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(deployer);
        challenge = new GuessTheNewNumberChallenge{value: 1 ether}();
    }

    function testAttack() external {
        // Deploy attack contract
        vm.startPrank(attacker);
        attack = new AttackGuessTheNewNumberChallenge(address(challenge));

        attack.attack{value: 1 ether}();
        vm.stopPrank();

        assertEq(attacker.balance, 2 ether);
        assert(challenge.isComplete());
    }
}
