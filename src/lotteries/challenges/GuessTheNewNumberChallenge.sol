// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GuessTheNewNumberChallenge {
    // function GuessTheNewNumberChallenge() public payable {
    //     require(msg.value == 1 ether);
    // }

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        // uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now));

        // if (n == answer) {
        //     msg.sender.transfer(2 ether);
        // }

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}
