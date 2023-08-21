// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GuessTheSecretNumberChallenge} from "../../src/lotteries/challenges/GuessTheSecretNumberChallenge.sol";

contract TestGuessTheSecretNumberChallenge is Test {
    GuessTheSecretNumberChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);

        challenge = new GuessTheSecretNumberChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

        // answerHash is not reversible
        // uint8 has a range from 0 to 255
        // so we can just brute force it until we get the right answer
        for (uint8 i = 0; i <= type(uint8).max; i++) {
            bytes32 currentHash = keccak256(abi.encodePacked(i));

            if (currentHash == answerHash) {
                // log result
                console.log("Correct answer: ", i);

                // call contract
                vm.prank(player);
                challenge.guess{value: 1 ether}(i);
                break;
            }
        }

        assert(player.balance == 2 ether);
        assert(challenge.isComplete());
    }
}
