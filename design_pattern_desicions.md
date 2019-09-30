# Design Pattern Decisions

## Design Patterns 

##### Restricting Access
This is achieved by inheriting from Onwable in the GLTMerchantSale contract.
The function "buyTokens()" must not be called by any other contract than of a merchant one's, because only he is supposed to buy tokens for Euros, as the Loyalty System will work in a way, that only the merchants should be able to distribute the tokens to their customers.

##### Mortal
If an account that is not owned by a merchant accesses the the "buyTokens()" function the contract has to be destroyed immediately as this should never possible for the reason just desribed in the section above.

##### Fail early and loud
Check in the function "redeemTokens()" already at the beginning of the function if the user / customer has got sufficient tokens for redeeming the provided amount of points. If this is not the case the function will throw an exception.
