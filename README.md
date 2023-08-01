# Capture the Ether Solutions

Solutions to the [Capture The Ether](https://capturetheether.com/challenges/) CTF challenges using Foundry ⛳️

## Contents

-   [Lotteries](#lotteries)
    -   [Guess the number](#guess-the-number)

## Lotteries

### Guess the number

Call the `guess` function with the `answer` number `42` which is hardcoded in the contract

```solidity
challenge.guess{value: 1 ether}(42);
```

[Test](./test/lotteries/TestGuessTheNumberChallenge.t.sol)
