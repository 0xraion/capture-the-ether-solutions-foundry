# Capture the Ether Solutions

Solutions to the [Capture The Ether](https://capturetheether.com/challenges/) CTF challenges using Foundry ⛳️

## Disclaimer

Most of the contracts were rewritten slightly so they still compile with newer solidity versions. Comments were added for those parts.

## Contents

-   [Lotteries](#lotteries)
    -   [Guess the number](#guess-the-number)
    -   [Guess the secret number](#guess-the-secret-number)
    -   [Guess the random number](#guess-the-random-number)

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

In this case the answer is generated "randomly" and stored "internally" in the contract (default visibility of state variables is 'internal'):

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
