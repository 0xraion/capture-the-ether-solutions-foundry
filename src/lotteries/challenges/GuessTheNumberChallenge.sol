// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GuessTheNumberChallenge {
    uint8 answer = 42;

    // function GuessTheNumberChallenge() public payable {
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

        if (n == answer) {
            // msg.sender.transfer(2 ether);
            payable(msg.sender).transfer(2 ether);
        }
    }
}
