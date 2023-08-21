// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

interface IAssumeOwnershipChallenge {
    function isComplete() external view returns (bool);

    function AssumeOwmershipChallenge() external;

    function authenticate() external;
}

contract TestAssumeOwnershipChallenge is Test {
    IAssumeOwnershipChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.prank(deployer);

        address challengeAddress = deployCode(
            "AssumeOwnershipChallenge.sol:AssumeOwnershipChallenge"
        );

        challenge = IAssumeOwnershipChallenge(challengeAddress);
    }

    function test_Solution() external {
        vm.startPrank(player);

        challenge.AssumeOwmershipChallenge();
        challenge.authenticate();

        assert(challenge.isComplete());
    }
}
