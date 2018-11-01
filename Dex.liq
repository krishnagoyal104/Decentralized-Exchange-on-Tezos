[%%version 0.403] 

type balance = {
  tezzies : nat;
  tokens : (address, nat)map;
}  

type storage = (address, balance)map     
  
let%init storage = (Map : (address, balance)map);
    
  contract type BytesContract = sig
             type storage
             val%entry main : bytes -> storage -> (operation list * storage)
           end  
             
let get_balance ((a : address), (storage : storage)) =
  match Map.find a storage with  
  | None -> { tezzies = 0p; tokens = (Map : (address, nat) map) }
  | Some account -> account 
    
let get_address (k : key) =  
  let key_hash = Crypto.hash_key k in   
  let account = Account.default key_hash in   
  Contract.address account  
    
let%entry main  
    (parameter : unit)
    (storage : storage) =  
  (([] : operation list), storage)
  
let%entry deposit
    (parameter : unit)  
    (storage : storage) = 
  let sender = Current.sender() in
  let amount = Current.amount() in  
  let amount_nat_option = amount/1tz in
  match amount_nat_option with 
  |None -> Current.failwith();
  |Some amount_nat_tuple -> 
      let (amount_nat, rem_tez) = amount_nat_tuple in
      let sender_balance = get_balance(sender, storage) in  
      let new_sender_balance =  sender_balance.tezzies <- amount_nat in  
      let storage = Map.add sender new_sender_balance storage in    
      (([] : operation list), storage)
  
let%entry withdraw
    (parameter : nat)
    (storage : storage) = 
  let sender = Current.sender() in 
  let sender_balance = get_balance(sender, storage) in  
  let new_sender_balance = match is_nat (sender_balance.tezzies - parameter) with      
    |None -> Current.failwith "Not enough balance"  
    |Some b -> sender_balance.tezzies <- b in  
  let storage = Map.add sender new_sender_balance storage in 
  let _contract = (Contract.at sender : UnitContract.instance option) in 
  match _contract with
  |None -> Current.failwith();
  |Some contr -> 
      let op = Contract.call ~dest:contr ~amount:(parameter * 1tz) () in
      ([op], storage) 

let%entry tokenFallback
    (parameter : bytes)
    (storage : storage) = 
  
  match (Bytes.unpack parameter : (address * nat) option) with 
  |None -> Current.failwith "Cannot unpack bytes";
  |Some data ->
      let (sender, amount) = data in
      let token_address = Current.sender() in  
      let sender_balance = get_balance(sender, storage) in  
      let new_sender_balance = match Map.find sender sender_balance.tokens with  
        |None -> Map.add token_address amount sender_balance.tokens  
        |Some b -> Map.add token_address (b + amount) sender_balance.tokens in  
      let sender_balance = sender_balance.tokens <- new_sender_balance in  
      let storage = Map.add sender sender_balance storage in        
      (([] : operation list), storage) 
        
let%entry tokenWithdraw 
    (parameter : address * nat)
    (storage : storage) =  
  let (token_address, amount) = parameter in  
  let sender = Current.sender() in  
  let sender_balance = get_balance(sender, storage) in  
  let new_sender_balance = match Map.find token_address sender_balance.tokens with  
    |None -> Current.failwith "Not enough balance"  
    |Some b -> 
        match is_nat (b - amount) with  
        |None -> Current.failwith "Not enough balance"  
        |Some n -> Map.add token_address n sender_balance.tokens in     
  let sender_balance = sender_balance.tokens <- new_sender_balance in  
  let storage = Map.add sender sender_balance storage in  
  let _contract = (Contract.at token_address : BytesContract.instance option) in
  match _contract with 
  |None -> Current.failwith();
  |Some contr -> 
      let args = Bytes.pack(sender, amount, false) in
      let op = Contract.call ~dest:contr ~entry:main ~parameter:(args) ~amount:0tz in
      (([op]), storage) 
  
let%entry trade
    (parameter : (bytes * signature))
    (storage : storage) =  
  let (data, sign) = parameter in
  let taker = Current.sender() in 
  match (Bytes.unpack data : (key * address * address * nat * nat) option) with 
  |None -> Current.failwith "Wrong arguments"; 
  |Some args -> 
      let (pub_key, tokenGet, tokenGive, amountGet, amountGive) = args in 
      let hash = Crypto.sha256 data in
      let success = Crypto.check pub_key sign hash in 
      if success <> true then Current.failwith "Wrong signature";                       
      let maker = get_address pub_key in           
      let maker_balance = get_balance(maker, storage) in  
      let new_maker_balance = match Map.find tokenGet maker_balance.tokens with  
        |None -> Map.add tokenGet amountGet maker_balance.tokens    
        |Some b -> Map.add tokenGet (b + amountGet) maker_balance.tokens in  
      let new_maker_balance = match Map.find tokenGive maker_balance.tokens with  
        |None -> Current.failwith "Maker doesn't have enough balance"  
        |Some b -> 
            match is_nat (b - amountGive) with  
            |None -> Current.failwith "Maker doesn't have enough balance"  
            |Some n -> Map.add tokenGive n maker_balance.tokens in  
      let maker_balance = maker_balance.tokens <- new_maker_balance in  
      let taker_balance = get_balance(taker, storage) in  
      let new_taker_balance = match Map.find tokenGet taker_balance.tokens with  
        |None -> Current.failwith "Taker doesn't have enough balance"  
        |Some b ->  
            match is_nat (b - amountGet) with  
            |None -> Current.failwith "Taker doesn't have enough balance"  
            |Some n -> Map.add taker n taker_balance.tokens in  
      let new_taker_balance = match Map.find tokenGive taker_balance.tokens with  
        |None -> Map.add tokenGive amountGive taker_balance.tokens  
        |Some n -> Map.add tokenGive (amountGive + n) taker_balance.tokens in  
        let taker_balance = taker_balance.tokens <- new_taker_balance in  
      let storage = Map.add maker maker_balance storage in  
      let storage = Map.add taker taker_balance storage in  
      (([] : operation list), storage)
      
            
            
            
      

          
