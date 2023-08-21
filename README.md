# Capture the Ether Solutions

Solutions to the [Capture The Ether](https://capturetheether.com/challenges/) CTF challenges using Foundry ⛳️

## Disclaimer

Most of the contracts were rewritten slightly so they still compile with newer solidity versions. Comments were added for those parts.

I also didn't add solutions for the accounts challenges because they are not related to smart contract vulnerabilites. If you want to read writeups for those challenges check out the writeups from [cmichel](https://cmichel.io/capture-the-ether-solutions/)

## Contents

- [Capture the Ether Solutions](#capture-the-ether-solutions)
  - [Disclaimer](#disclaimer)
  - [Contents](#contents)
  - [Lotteries](#lotteries)
    - [Guess the number](#guess-the-number)
    - [Guess the secret number](#guess-the-secret-number)
    - [Guess the random number](#guess-the-random-number)
    - [Guess the new number](#guess-the-new-number)
    - [Predict the future](#predict-the-future)
    - [Predict the block hash](#predict-the-block-hash)
  - [Math](#math)
    - [Token sale](#token-sale)
    - [Token whale](#token-whale)
    - [Retirement Fund](#retirement-fund)
    - [Mapping](#mapping)
    - [Donation](#donation)
    - [Fifty Years](#fifty-years)
  - [Miscellaneous](#miscellaneous)
    - [Assume ownership](#assume-ownership)
    - [Token bank](#token-bank)
- [Acknowledgments](#acknowledgments)

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
                vm.prank(player);
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

### Predict the block hash

We now have to predict the hash of a future block, which will not be possible to brute-force:

```solidity
function lockInGuess(bytes32 hash) public payable {
  guess = hash;
  settlementBlockNumber = block.number + 1;
}

function settle() public {
  require(block.number > settlementBlockNumber);
  bytes32 answer = blockhash(settlementBlockNumber);
}

```

But there is a catch! From [Solidity documentation](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#block-and-transaction-properties):

> The block hashes are not available for all blocks for scalability reasons. You can only access the hashes of the most recent 256 blocks, all other values will be zero.

This means that after 256 + 1 + 1 blocks of locking our guess our "random" answer will be 0. So we we can exploit it:

1. Call `lockInGuess` with `bytes32(uint256(0))`
2. Wait for 258 blocks (257 blocks + 1 block because `settlementBlockNumber = block.number + 1`)
3. Call `settle`

[Test](./test/lotteries/TestPredictTheBlockHashChallenge.t.sol)

## Math

### Token sale

The goal here is to steal some Ether from the contract.

In older versions of Solidity you could perform an overflow without reverting the tx. This [was changed in v0.8.0](https://docs.soliditylang.org/en/v0.8.13/080-breaking-changes.html#silent-changes-of-the-semantics).

It is possible to exploit the contract with that in mind tricking the `require`:

```solidity
function buy(uint256 numTokens) public payable {
  require(msg.value == numTokens * PRICE_PER_TOKEN);

  balanceOf[msg.sender] += numTokens;
}

```

We can calculate the value of `numTokens` that makes the calculation overflow, and the amount of wei that has to be sent:

```solidity
numTokens = (type(uint256).max / PRICE_PER_TOKEN) + 1;
msg.value = numTokens * PRICE_PER_TOKEN;
```

The resulting `msg.value` is around `0.41` ETH. Then, 1 token can be sold for 1 ETH, completing the challenge.

[Test](./test/math/TestTokenSaleChallenge.t.sol)

### Token whale

The goal of this challenge is to accumulate at least 1,000,000 tokens with a starting balance and total supply of 1,000 tokens.

We can exploit this contract by underflowing a variable, converting it into a huge number of tokens:

```solidity
function transferFrom(
  address from,
  address to,
  uint256 value
) public {
  require(balanceOf[from] >= value);
  require(balanceOf[to] + value >= balanceOf[to]);
  require(allowance[from][msg.sender] >= value);

  allowance[from][msg.sender] -= value;
  _transfer(to, value);
}

function _transfer(address to, uint256 value) internal {
  balanceOf[msg.sender] -= value; // <======== THIS
  balanceOf[to] += value;

  emit Transfer(msg.sender, to, value);
}
```

If we can make `balanceOf[msg.sender] -= value;` underflow, we'll solve the challenge.

In order to do that, the balance of the `msg.sender` has to be lower than the `value` of tokens.

It wouldn't be possible in a simple `transfer()`, as it checks the balance of the `msg.sender`.

On the other hand, `transferFrom()` calls `_transfer()` but only checks the allowance and not the balance of `msg.sender`.

With all of this information we're able to perform the attack:

1. Transfer 501 tokens from the player to another player controlled address
2. The balance of the Attacker will be 499 and the Secondary Account will be 501
3. Approve to spend 500 tokens from the original address
4. Let the Attacker call `transferFrom` to move 500 tokens from the Secondary Account to his own address

The Secondary account has enough balance (501 - 500), so it passes the `require` statements.

The Attacker account balance will underflow (499-500), so instead of resulting in -1, it is MAX_UINT_256, exploiting the contract.

[Test](./test/math/TestTokenWhaleChallenge.t.sol)

### Retirement Fund

In this challenge we're the `beneficiary` of part of a retirement fund if the `owner` withdraws the Ether early.

The only callable function by the `beneficiary` is `collectPenalty`:

```solidity
function collectPenalty() public {
  require(msg.sender == beneficiary);

  uint256 withdrawn = startBalance - address(this).balance;
  require(withdrawn > 0);

  msg.sender.transfer(address(this).balance);
}
```

Here we can "bypass" the `require(withdrawn > 0)` if we can perform an underflow in `startBalance - address(this).balance`.

It doesn't seem to be possible to add more funds with any function, and the contract does not have a [payable fallback function](https://docs.soliditylang.org/en/develop/contracts.html#fallback-function). So it shouldn't be possible to do it, right?

But there are other ways to force sending Ether to a contract. In this case we're making use of the following:

[Docs](https://solidity-by-example.org/hacks/self-destruct/)

> A malicious contract can use selfdestruct to force sending Ether to any contract.

We can create a contract that autodestructs and sends Ether to the original contract address, perform an underflow, and then withdraw the funds

[Test](./test/math/TestRetirementFundChallenge.t.sol)

### Mapping

In this challenge we have to make `isComplete` return `true`, but there doesn't seem to be any place to change it.

```solidity
contract MappingChallenge {
  bool public isComplete;
  uint256[] map;

  function set(uint256 key, uint256 value) public {
    if (map.length <= key) {
      map.length = key + 1;
    }

    map[key] = value;
  }

  function get(uint256 key) public view returns (uint256) {
    return map[key];
  }
}
```

There are only two places that modify the storage: `map.length = key + 1;` and `map[key] = value;`. So we may want to check if we can exploit that somehow.

[Contracts have a storage of 2^256 slots of 32-bytes](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html).

> State variables of contracts are stored in storage in a compact way such that multiple values sometimes use the same storage slot. Data is stored contiguously item after item starting with the first state variable, which is stored in slot 0.

That said, we know that `isComplete` is stored in `slot 0`.

> Due to their unpredictable size, mappings and dynamically-sized array types cannot be stored “in between” the state variables preceding and following them. Instead, they are considered to occupy only 32 bytes with regards to the rules above and the elements they contain are stored starting at a different storage slot that is computed using a Keccak-256 hash.

Using this info we can set isComplete to true with the following steps:

1. Calculate starting slot of array entries 
```solidity
uint256 startingSlot = uint256(keccak256(abi.encode(1)));
```
2. Using an overflow we can get to storage `slot 0` where isComplete is stored
```solidity
uint256 attackSlot = type(uint256).max - startingSlot + 1;
```
3. Set isComplete to 1
```solidity
challenge.set(attackSlot, 1);
```

[Test](./test/math/TestMappingChallenge.t.sol)

### Donation

In this challenge we have to withdraw all the Ether from the contract. The only place where it is possible is:

```solidity
function withdraw() public {
  require(msg.sender == owner);
  msg.sender.transfer(address(this).balance);
}
```

But it requires to be the `owner`. So, we'll have to find a way to become the new owner.

That's where we get to the `donate()` function which has 2 major problems.
First it calculates `scale` wrong, as it results in 10**36.
Also the `donation` variable has no location defined.

```solidity
Donation donation;
```

In this case, it assumes `storage` by default, leading to an unexpected behavior. It acts as a pointer to the storage, and it will write to the first slots when changing its attributes:

```solidity
struct Donation {
  uint256 timestamp;
  uint256 etherAmount;
}

Donation[] public donations;
address public owner;
```

Setting the `timestamp` will write to the `slot 0` => the array length, and setting `etherAmount` will write to the `slot 1` => the `owner`.

So, to set the `owner` we just have to set `etherAmount` to our address.

The only reamaining challenge is passing the `require(msg.value == etherAmount / scale);`

It is straightforward. We convert our a decimal number and divide by the `scale` (10**36)

[Test](./test/math/TestDonationChallenge.t.sol)

### Fifty Years

The goal of this challenge is to withdraw all the Ether from the contract.

In order to do that we will need to call the `withdraw` function and satisfy two requirements. We're the `owner`, so that's fine. The second conditions is that we wait 50 years to withdraw the Ether:

```solidity
function withdraw(uint256 index) public {
  require(msg.sender == owner);
  require(now >= queue[index].unlockTimestamp);
  // ...
  msg.sender.transfer(total);
}
```

50 years is too long, so we'll try to find a way of modifying `queue[index].unlockTimestamp`, so that it satisfies the requirement.

```solidity
function upsert(uint256 index, uint256 timestamp) public payable {
  if (index >= head && index < queue.length) {
    Contribution storage contribution = queue[index];
    contribution.amount += msg.value;
  } else {
    require(timestamp >= queue[queue.length - 1].unlockTimestamp + 1 days);

    contribution.amount = msg.value;
    contribution.unlockTimestamp = timestamp;
    queue.push(contribution);
  }
}
```

There's a vulnerability that might be exploited here. The `contribution` variable has an [uninitialized storage pointer](https://www.bookstack.cn/read/ethereumbook-en/spilt.16.c2a6b48ca6e1e33c.md#n76zm). Meaning that modifying it will modify the first slots of the storage: `contribution.amount` will change the `slot 0`, which corresponds to the array length, and `contribution.unlockTimestamp` will modify the `slot 1`, which is the `head` variable.

First we will expand the array length, so that we can later modify any slot in the storage. We also have to satisfy this condition:

```solidity
require(timestamp >= queue[queue.length - 1].unlockTimestamp + 1 days);
```

So, we will satisfy the condition by overflowing the result in a way that it equals `0` => `timestamp = 2^256 - 1 day`. We will also send `value = 1`, so that it updates `contribution.amount => slot 0 => array length`.

Then we have to reset the `head` value which was overwritten previously with garbage. This will also increase the array length by one.

We can finally create a contract that autodestructs and sends the remaining wei we need to pass the `withdraw` requirements.

Call `withdraw` and we're done :)

## Miscellaneous

### Assume ownership

The constructor function was misspelled making it public. We simply have to call it to solve this challenge.

[Test](./test/miscellaneous/AssumeOwnershipChallenge.t.sol)

### Token bank

This token bank contract uses an ERC-223 token. This token standard calls `tokenFallback()` on the recipient of a `transfer()` in case it is a contract. 
Knowing this we immediately want to look for possible re-entrancy attacks. 
And thats how we solve this challenge. In this case the balance is updated after calling the `transfer()` function. 
So it is possible to create a contract which exploits that via a re-entrancy attack and withdraw all the tokens.

[Test](./test/miscellaneous/TokenBankChallenge.t.sol)

# Acknowledgments

The following ressources were a big help in solving this CTF:
- [Solidity Docs](https://docs.soliditylang.org/en/v0.8.21/)
- [Solidity by Example](https://solidity-by-example.org/)
- [Solutions and Writeups by 0xJuancito](https://github.com/0xJuancito/capture-the-ether-solutions)
- [Writeups by cmichel](https://cmichel.io/capture-the-ether-solutions/)

I especially want to thank [0xJuancito](https://github.com/0xJuancito) because I used most of his writeups cause I couldn't have worded them better myself
