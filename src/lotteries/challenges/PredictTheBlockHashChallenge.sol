// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    // function PredictTheBlockHashChallenge() public payable {
    //     require(msg.value == 1 ether);
    // }

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        // require(guesser == 0);
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        // bytes32 answer = block.blockhash(settlementBlockNumber);
        bytes32 answer = blockhash(settlementBlockNumber);

        // guesser = 0;
        guesser = address(0);

        if (guess == answer) {
            // msg.sender.transfer(2 ether);
            payable(msg.sender).transfer(2 ether);
        }
    }
}
