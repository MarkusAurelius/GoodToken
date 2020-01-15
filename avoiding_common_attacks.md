# Mitigating Know Attacks

The contracts developed for this project, implement a series of design patterns and best practices, such as:

## Attacks and Best Practices Implemented

##### Re-entrancy attacks
Problem:
A Smart Contract may communicate with an external Smart Contract by “calling it”. If the  external Smart Contract is malicious, it may be able to  take advantage of this and take over control flow of the first Smart Contract’s code.
This allows the attacker to make unexpected changes to the first Smart Contract’s code. For example, it may repeatedly withdraw Ether from the Smart Contract by “re-entering” at a particular spot in the code. 

Applied Solution:
Using the Reentrant modifier will prevent nested calls in the function buyTokens() of the GLTMerchantSale contract. 
This modifier is implemented in the contract ReentrancyGuard, which is the super contract of Crowdsale, which are both part of the Open-Zeppelin-Contract libraries. GLTMerchantSale is again derived from the Crowdsale contract.
The guardCounter in this mentioned modifier implements the mutex capability for the applied function (in my case buTokens()). 

##### Integer Overflow / -Underflow
Problem:
Integers can underflow or overflow in the EVM.
The max value for an unsigned integer is 2 ^ 256 - 1, which is roughly 1.15 times 10 ^ 77. If an integer overflows, the value will go back to 0. For example, a variable called score of type uint8 storing a value of 255 that is incremented by 1 will now be storing the value 0.

Applied Solution:
- This risks should be mitigated by applying the SafeMath library for all mathematical operations.
- Moreover Require checks are implemented for the number of tokens to be collected and to be redeemed. It isn't possible to collect more tokens than a merchant possesses or to redeem more tokens than a customer has got on his balance sheet.

##### Denial of Service by Block Gas Limit (or startGas)
Problem:
There is a limit to how much computation can be included in a single Ethereum block, currently 8,000,000 gas worth. This means that if your smart contract reaches a state where a transaction requires more than 8,000,000 gas to execute, that transaction will never successfully execute.  It will always reach the block gas limit before finishing.

Applied Solution:
There is no implementation of any iterations over (infinite) arrays which could cause this kind of attack.
