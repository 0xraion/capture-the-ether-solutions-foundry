// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GuessTheRandomNumberChallenge} from "../../src/lotteries/GuessTheRandomNumberChallenge.sol";

contract TestGuessTheRandomNumberChallenge is Test {
    GuessTheRandomNumberChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        challenge = new GuessTheRandomNumberChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        // answer variable is generated "randomly" and has internal visibility (default visibilty for state variables)
        // data in smart contracts can still be read despite being declared as "internal" or "private"
        // to do that we need to understand how storage works and how to read storage slots

        // in this case we need to access storage slot 0 to access the answer variable
        uint8 answer = uint8(uint256(vm.load(address(challenge), 0)));

        vm.prank(player);
        challenge.guess{value: 1 ether}(answer);

        assert(player.balance == 2 ether);
        assert(challenge.isComplete());
    }
}
