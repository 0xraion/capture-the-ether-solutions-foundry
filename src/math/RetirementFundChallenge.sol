// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract RetirementFundChallenge {
    uint256 startBalance;
    address owner = msg.sender;
    address beneficiary;
    // uint256 expiration = now + 10 years;
    uint256 expiration = block.timestamp + 3650 days;

    // function RetirementFundChallenge(address player) public payable {
    //     require(msg.value == 1 ether);

    //     beneficiary = player;
    //     startBalance = msg.value;
    // }

    constructor(address player) payable {
        require(msg.value == 1 ether);
        beneficiary = player;
        startBalance = msg.value;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function withdraw() public {
        require(msg.sender == owner);

        // if (now < expiration) {
        //     // early withdrawal incurs a 10% penalty
        //     msg.sender.transfer(address(this).balance * 9 / 10);
        // } else {
        //     msg.sender.transfer(address(this).balance);
        // }

        if (block.timestamp < expiration) {
            // early withdrawal incurs a 10% penalty
            msg.sender.transfer(address(this).balance * 9 / 10);
        } else {
            msg.sender.transfer(address(this).balance);
        }
    }

    function collectPenalty() public {
        require(msg.sender == beneficiary);

        uint256 withdrawn = startBalance - address(this).balance;

        // an early withdrawal occurred
        require(withdrawn > 0);

        // penalty is what's left
        msg.sender.transfer(address(this).balance);
    }
}