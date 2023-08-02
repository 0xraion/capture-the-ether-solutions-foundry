// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GuessTheSecretNumberChallenge} from "../../src/lotteries/GuessTheSecretNumberChallenge.sol";

contract TestGuessTheSecretNumberChallenge is Test {
    GuessTheSecretNumberChallenge challenge;

    address deployer;
    address user;

    function setUp() external {
        deployer = address(1);
        user = address(2);

        vm.deal(deployer, 1 ether);
        vm.prank(deployer);

        challenge = new GuessTheSecretNumberChallenge{value: 1 ether}();
    }

    function testIsComplete() external {
        vm.deal(user, 1 ether);

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
                vm.prank(user);
                challenge.guess{value: 1 ether}(i);
            }
        }

        assertEq(user.balance, 2 ether);
        assert(challenge.isComplete());
    }
}
