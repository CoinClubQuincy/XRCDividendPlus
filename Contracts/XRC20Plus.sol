pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//-------------------------- Plus Treasury Contract --------------------------
interface Plus_Interface {
    function View_Account() external view returns(uint); // -- ✓
    function Balance() external view returns(uint256);   // -- ✓
    function Accept_From_CoinBank(uint)external payable;
    function Redeem()external returns(bool);            // -- ✓
    function Register_Account()external returns(bool);  // -- ✓
}
contract Plus is ERC20, Plus_Interface {
    uint counter =0;
    uint Account_Counter = 0;
    uint dust_min = 100; // amount of dust allowed in treasury per refreash
    uint i=0; // -- change to CurrentUserCount
    event TreasuryClock( uint256,bool);

    //mappings map Account amounts and micro ledger
    mapping (address => Accounts) public accounts;
    mapping (uint => Accounts) public ledger;
    
    //CoinBank Contract
    address public CoinBank_Contract;
    //Account Details
    struct Accounts{
        uint ammount;
        bool exist;
    }
    //launch Contract
    constructor(string memory name,string memory symbol,uint totalSupply,uint8 decimals) ERC20(name, symbol) {        
        totalSupply = totalSupply*(10**decimals);
        _mint(msg.sender, uint(totalSupply));
        Register_Account();
        //------------------launch Conbank Contract------------------
        CoinBank incomingbank = new CoinBank(address(this),totalSupply);
        CoinBank_Contract = incomingbank;
    }
    //require coinbank 
    modifier CoinBankOnly{
        require(keccak256(abi.encodePacked(CoinBank_Contract[0])) == keccak256(abi.encodePacked(msg.sender)),"Only Contract coinbank can execute this function");
        _;
    }
    //Test logging and accounting user dividends
    function Register_Account() public returns(bool){
        require(accounts[msg.sender].exist == false,"user already exist");
        ledger[Account_Counter] = Accounts(msg.sender,true);
        accounts[msg.sender] = Accounts(0,true);
        Account_Counter++;
        return true;
    }   
    //Account of your funds in contract
    function View_Account() public view returns(uint){
        require(accounts[msg.sender].exist == true,"user not registerd");
        return accounts[msg.sender].ammount;
    }
    //call contract balance
    function Balance() public view returns(uint256) {
        return address(this).balance;
    }
    //Accept payment from CoinBank and issue dividends to accouts
    function Accept_From_CoinBank(uint _singleShard)public payable CoinBankOnly{
        uint value = msg.value;
        uint totalAllocated=0;
        uint amountAllocated;

        for(i;i<=Account_Counter;i++){
            (i,amountAllocated) = InternalAccounting(i,_singleShard);
            totalAllocated += amountAllocated;
        }
        emit TreasuryClock(block.timestamp,true); 
    }
    //counts all the accounts in the Treasury
    function CountRegisterdShards() public view returns(uint){
        uint count =0;
        uint totalAccounts=0;
        for(count;count<=Account_Counter;count++){
            if(ledger[count].ammount > 0){
                totalAccounts++;
            }
        }
        return totalAccounts;
    }
    //
    function InternalAccounting(uint _shardHolder,uint _singleShard)internal returns(uint,uint){
        address Serach_result = ledger[_shardHolder].account;
        if(balanceOf(ledger[_shardHolder].account) > 0){
            accounts[Serach_result].ammount += balanceOf(ledger[_shardHolder].account) * _singleShard;
        } else{
            InternalAccounting(_shardHolder++,_singleShard);
        }
        return (_shardHolder,accounts[Serach_result].ammount);      
    }
    //Redeem Dividends from treasury
    function Redeem()public returns(bool){
        address payable RedeemAddress = payable(msg.sender);
        require(accounts[RedeemAddress].exist == true,"User does not exist");
        uint redeemValue = accounts[msg.sender].ammount;
        accounts[msg.sender].ammount=0;
        RedeemAddress.transfer(redeemValue);
        return true;     
    }
    fallback() external payable {
        //return funds
    }
    receive() external payable {}
}

//-------------------------- CoinBank Accounting Contract --------------------------
interface CoinBank_Interface{
    function Incomming_Payments()external payable returns(bool); // -- ✓
     function Balance() external view returns(uint256);
}
contract CoinBank is CoinBank_Interface{
    uint timeInterval;  
    event CoinBankClock(uint256,bool);
    address public Treasury;
    // Keep track of Funds in CoinBank
    struct CoinBank_Accounting{
        uint Previous_Time;
    }
    
    constructor(address _Treasury,uint _timeInterval) payable{
        Treasury = _Treasury;
        Bank[Treasury] = CoinBank_Accounting(block.timestamp);   
        Treasury = payable(Treasury);
        timeInterval = _timeInterval;
    }
    //CoinBank Index of all DAO Banks
    mapping (address => CoinBank_Accounting) public Bank;

    // Send funds to Treasury Contract
    function Issue_ToTreasury(uint _single_Shard)internal {
        Plus_Interface(payable(Treasury)).Accept_From_CoinBank{value:address(this).balance}(_single_Shard); //place treasury contract address here
        emit CoinBankClock(block.timestamp,true); 
    }
    // Payments to CoinBank will take account of funds and alocat them to the treasury
    function Incomming_Payments()public payable returns(bool){
        uint Supply = Plus_Interface(Treasury).CountRegisterdShards();
        // add one timeInterval to the int 60
        if(block.timestamp>=timeInterval+Bank[Treasury].Previous_Time){
            uint single_Shard = uint(address(this).balance/Supply);
            Issue_ToTreasury(single_Shard); //Call Accept from CoinBank
            Bank[Treasury].Previous_Time = block.timestamp;
            return true;
        }else{
            return false;
        }
    }
    //call contract balance
    function Balance() public view returns(uint256) {
        return address(this).balance;
    }
    receive () external payable {
        Incomming_Payments();
    }
    fallback() external payable {}
}