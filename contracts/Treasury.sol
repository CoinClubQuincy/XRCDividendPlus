pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Treasury_Interface {
    function View_Account() external view returns(uint);  // -- ✓
    function Redeem()external returns(bool);              // -- ✓
    function Register_Account()external returns(bool);    // -- ✓
    function CountRegisterdShards()external returns(uint);// -- ✓
}
contract Treasury is ERC20, Treasury_Interface {
    uint counter =0;
    uint public Account_Counter = 0;
    uint public totalAllocated=0;
    //mappings map Account amounts and micro ledger
    mapping (address => Accounts) public accounts;
    mapping (uint => Ledger) public ledger;
    //Account Details
    struct Accounts{
        uint amount;
        bool exist;
    }
    //Ledger
    struct Ledger{
        address account;
        bool exist;
    }
    //launch Contract
    constructor(string memory name,string memory symbol,uint totalSupply,uint8 decimals) ERC20(name, symbol) {
        totalSupply = totalSupply*(10**decimals);
        _mint(msg.sender, uint(totalSupply));
        Register_Account();
    }
    //Only Token Holders can use contract
    modifier TokenHolder{
        require(balanceOf(msg.sender) > 0, "only token holders can access");
        _;
    }
    //Test logging and accounting user dividends
    function Register_Account() public TokenHolder returns(bool){
        require(accounts[msg.sender].exist == false,"user already exist");
        ledger[Account_Counter] = Ledger(msg.sender,true);
        accounts[msg.sender] = Accounts(0,true);
        Account_Counter++;
        return true;
    }   
    //Account of your funds in contract
    function View_Account() TokenHolder public view returns(uint){
        require(accounts[msg.sender].exist == true,"user not registerd");
        return accounts[msg.sender].amount;
    }
    //Accept payment from CoinBank and issue dividends to accounts
    function callFromFallback(uint _singleShard)internal{
        uint amountAllocated;
        uint CurrentCount=0;

        for(CurrentCount;CurrentCount<Account_Counter;CurrentCount++){
            (CurrentCount,amountAllocated) = InternalAccounting(CurrentCount,_singleShard);
            totalAllocated += amountAllocated;
        }
    }
    //Counts all the accounts in the Treasury
    function CountRegisterdShards() public view returns(uint){
        uint count =0;
        uint totalAmount=0;
        for(count;count<=Account_Counter-1;count++){
            if(balanceOf(ledger[count].account) >0){
                totalAmount += balanceOf(ledger[count].account);
            }
        }
        return totalAmount;
    }
    //Sorts funds into accounts
    function InternalAccounting(uint _shardHolder,uint _singleShard)internal returns(uint,uint){
        address Serach_result = ledger[_shardHolder].account;
        if(balanceOf(ledger[_shardHolder].account) > 0){
            accounts[ledger[_shardHolder].account].amount += balanceOf(ledger[_shardHolder].account) * _singleShard;
        } else{
            InternalAccounting(_shardHolder++,_singleShard);
        }
        return (_shardHolder,accounts[Serach_result].amount);      
    }
    //Redeem Dividends from treasury
    function Redeem()public returns(bool){
        address payable RedeemAddress = payable(msg.sender);
        require(accounts[RedeemAddress].exist == true,"User does not exist");
        require(accounts[msg.sender].amount > 0, "account value 0");
        uint redeemValue = accounts[msg.sender].amount;
        accounts[msg.sender].amount=0;
        RedeemAddress.transfer(redeemValue);
        return true;     
    }
    //Payments made to the contract
    receive() external payable {
        uint Supply = CountRegisterdShards();
        // add one timeInterval to the int 60
        uint single_Shard = msg.value/Supply;
        callFromFallback(single_Shard); //place treasury contract address here(single_Shard); //Call Accept from CoinBank
    }
}