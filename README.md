# Decentralized-Exchange-on-Tezos

## Zeronet:
* The contract has been deployed on the zeronet.  
* Address :  KT1CvW3fKpp4xUercCem8QXN32YeJ4LQUzQP
 
## Deposit:  

* Tezzies can be deposited using this function.

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




