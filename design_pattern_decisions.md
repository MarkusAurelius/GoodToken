# Design Pattern Decisions

## Design Patterns 

##### Restricting Access
This is achieved by inheriting from Onwable in the GLTMerchantSale contract.
The function "buyTokens()" must not be called by any other contract than of a merchant one's, because only he is supposed to buy tokens for Euros, as the Loyalty System will work in a way, that only the merchants should be able to distribute the tokens to their customers.

##### Mortal
If an account that is not owned by a merchant accesses the 'buyTokens()' function the contract has to be destroyed immediately as this should never possible for the reason just desribed in the section above.

##### Fail early and loud
Check in the function "redeemTokens()" already at the beginning of the function if the user / customer has got sufficient tokens for redeeming the provided amount of points. If this is not the case the function will throw an exception.

##### Circuit Breaker
The logic of the Circuit Breaker is implemented in the contract Pausable.sol. This base contracts delivers functions to trigger a pausable state. Moreover it provides modifiers such as 'whenPaused' or 'whenNotPaused'. The access of the inherited contracts can be restricted during circuit breaks. The contract [GoodLifeToken.sol] is inherited from [Pausable.sol], which provides modifiers 'whenNotPaused' for the functions 'collectTokens()' and 'redeemTokens()' in the inherited conttract in order to ensure the execution of those functions only in case the contract is not in the paused state. 
