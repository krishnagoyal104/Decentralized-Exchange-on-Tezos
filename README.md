# Decentralized-Exchange-on-Tezos

## Deposit:  

* Tezzies can be deposited using this function.
* The amount is stored in a map where the key is the owner and token_address(0 for tezzies) compressed into bytes.

## Withdraw:  
* To withdraw tezzies.

## TokenFallback:
*  To deposit contract tokens.
* This function is in compliance with ERC223 similar specification. Users do not need to approve the tokens to the dex contract, these can be directly sent using the transfer function.

## TokenWithdraw:  
* To withdraw contract tokens.  

## Trade  
* This function takes in bytes and a signature as arguments.
* The market_maker needs to sign the hash of the arguments which is then published by the taker.




