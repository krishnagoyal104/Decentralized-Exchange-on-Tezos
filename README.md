# Decentralized-Exchange-on-Tezos  
* An implementation of a decentralized exchange on Tezos written in Liquidity and Michelson.  
* A decentralized exchange is an exchange where tokens can be traded peer to peer without a third party service, using smart contracts.  
* The exchange is built in compliance with ERC223 similar token standard for Tezos :       
https://github.com/krishnagoyal104/Tezos-Token-Standard

## Zeronet:
* The contract has been deployed on the zeronet.  
* Address :  KT1CvW3fKpp4xUercCem8QXN32YeJ4LQUzQP
* The contract can be interacted with using the Liquidity IDE : http://www.liquidity-lang.org/edit  

## Contract Entry Points:  

### Deposit:     
* To deposit tezzies.   

### Withdraw:  
* To withdraw tezzies.

### TokenFallback:
*  To deposit contract tokens.
* This function is in compliance with ERC223 similar specification. Users do not need to approve the tokens to the dex contract, these can be directly sent using the transfer function.

### TokenWithdraw:  
* To withdraw contract tokens.  

### Trade  
* This function takes in bytes and a signature as arguments and is called by the taker.  
* The market_maker needs to sign the hash of the arguments which is then published by the taker.  




