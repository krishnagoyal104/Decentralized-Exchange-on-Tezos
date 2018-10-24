[%%version 0.401] 

type storage = 
  { 
    number : nat;
    balances : (bytes, nat)map; 
  } 

let%entry deposit
    (parameter : unit)  
    (storage : storage) = 
  let sender = Current.sender() in
  let amount = Current.amount() in 
  let key = Bytes.pack (sender, 0) in
  let amount_nat_option = amount/1tz in
  match amount_nat_option with 
  |None -> Current.failwith();
  |Some amount_nat_tuple -> 
      let (amount_nat, rem_tez) = amount_nat_tuple in
      let storage = storage.balances <- Map.add key amount_nat storage.balances in 
      (([] : operation list), storage)
  
let%entry withdraw
    (parameter : nat)
    (storage : storage) = 
  let sender = Current.sender() in 
  let key = Bytes.pack (sender, 0) in
  match Map.find key storage.balances with 
  |None -> Current.failwith "Not enough balance";
  |Some value -> 
      match%nat value-parameter with 
      |Minus m -> Current.failwith ("Not enough balance", m);
      |Plus p ->
          let storage = storage.balances <- Map.add key p storage.balances in 
          let _contract = (Contract.at sender : UnitContract.instance option) in 
          match _contract with
          |None -> Current.failwith();
          |Some contr -> 
              let op = Contract.transfer contr (parameter * 1tz) in
              (([op]), storage) 

let%entry tokenFallback
    (parameter : bytes)
    (storage : storage) = 
  
  match (Bytes.unpack parameter : (address * nat) option) with 
  |None -> Current.failwith "Cannot unpack bytes";
  |Some data ->
      let (sender, value) = data in
      let tokenAddress = Current.sender() in 
      let key = Bytes.pack (sender, tokenAddress) in 
      let storage = storage.balances <- Map.add key value storage.balances in 
      (([] : operation list), storage) 
        
let%entry tokenWithdraw 
    (parameter : address * nat)
    (storage : storage) = 
  let (tokenAddress, amount) = parameter in
  let sender = Current.sender() in
  let key = Bytes.pack (sender, tokenAddress) in
  match Map.find key storage.balances with 
  |None -> Current.failwith "Not enough balace";
  |Some value ->
      match%nat value-amount with 
      |Minus m -> Current.failwith ("Not enough balance", m); 
      |Plus p -> 
          let storage = storage.balances <- Map.add key p storage.balances in
          let _contract = (Contract.at tokenAddress : BytesContract.instance option) in
          match _contract with 
          |None -> Current.failwith();
          |Some contr -> 
              let args = Bytes.pack(sender, amount, false) in
              let op = Contract.call ~dest:contr ~entry:main ~parameter:(args) ~amount:0tz in
              (([] : operation list), storage) 
  
let%entry trade
    (parameter : (bytes * signature))
    (storage : storage) =  
  let (data, sign) = parameter in
  let sender = Current.sender() in 
  match (Bytes.unpack data : (key * address * address * nat * nat) option) with 
  |None -> Current.failwith "Wrong arguments"; 
  |Some args -> 
      let (pub_key, tokenGet, tokenGive, amountGet, amountGive) = args in 
      let hash = Crypto.sha256 data in
      let success = Crypto.check pub_key sign hash in 
      let key_hash = Crypto.hash_key pub_key in
      let market_maker = Account.default key_hash in
      if success <> true then Current.failwith "Wrong signature";
      let key1 = Bytes.pack (sender, tokenGet) in
      let key2 = Bytes.pack (market_maker, tokenGet) in
      match Map.find key1 storage.balances with 
      |None -> Current.failwith();
      |Some tokenGet_bal -> 
          match%nat tokenGet_bal - amountGet with 
          |Minus m -> Current.failwith ("Not enough balance", m);
          |Plus p -> 
              let storage = storage.balances <- Map.add key1 p storage.balances in
              match Map.find key2 storage.balances with 
              |None -> Current.failwith();
              |Some tokenGet_bal_ -> 
                  let storage = storage.balances <- Map.add key2 (tokenGet_bal_+amountGet) storage.balances in
                  (([] : operation list), storage)
      
      


          
  
        
        
    
 


  
  
  
  
         
