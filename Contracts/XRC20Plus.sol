pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//-------------------------- CoinBank Accounting Contract --------------------------
interface CoinBank_Interface{
    function Incomming_Payments()external payable; // -- ✓
}
contract CoinBank is CoinBank_Interface{
    uint Shard_yeild_deposit; 
    uint Supply;
    uint Fund_Retention_Rate; 
    address Treasury;
    uint totalBanks;
    event CoinBankClock(uint256,bool);

    // Keep track of Funds in CoinBank
    struct CoinBank_Accounting{
        uint Current_Funds_Retained;
        uint Previous_Time;
    }
    constructor(address _Treasury,uint _supply){
        Bank[0] = CoinBank_Accounting(0,block.timestamp);
        Treasury = _Treasury;
        Supply = _supply;
    }
    //CoinBank Index of all DAO Banks
    mapping (uint256 => CoinBank_Accounting) public Bank;

    // Send funds to Treasury Contract
    function Issue_To_Treasury(uint _single_Shard)internal{
       // send data through interface function
        Plus_Interface exeInterface = Plus_Interface(Treasury); //place treasury contract address here
        exeInterface.Accept_From_CoinBank(_single_Shard);
        emit CoinBankClock(block.timestamp,true); 
    }
    // Payments to CoinBank will take account of funds and alocat them to the treasury
    function Incomming_Payments()public payable{
        uint min=0; // add one min to the int
        if(block.timestamp<=min+Bank[0].Previous_Time){
            uint single_Shard = uint(address(this).balance/Supply);
            Issue_To_Treasury(single_Shard); //Call Accept from CoinBank
        }
    }
    fallback() external payable {}
    receive() external payable {
        if(msg.value>0){
            payable(address(this)).transfer(msg.value);
        }
    }
}
//-------------------------- Plus Treasury Contract --------------------------
interface Plus_Interface {
    function View_Account() external view returns(uint); // -- ✓
    function Balance() external view returns(uint256);   // -- ✓
    function Accept_From_CoinBank(uint)external payable;
    function Redeem()external returns(bool);            // -- ✓
    function Register_Account()external returns(bool);  // -- ✓
}
abstract contract Plus is ERC20, Plus_Interface {
    uint counter =0;
    uint Account_Counter = 0;
    uint dust_min = 100; //min amount of dust allowed in treasury per refreash
    uint i=0; // -- change to CurrentUserCount
    event TreasuryClock( uint256,bool);

    //mappings map Account amounts and micro ledger
    mapping (address => Accounts) public accounts;
    mapping (uint => micro_ledger) public ledger;
    
    //CoinBank Contract
    CoinBank public CoinBank_Contract;
    //Account Details
    struct Accounts{
        uint ammount;
        bool exist;
    }
    //Micrledger holds all accounts ever
    struct micro_ledger{
        address account;
        bool exist;
    }
    //launch Contract
    constructor(string memory name,string memory symbol,uint totalSupply,uint8 decimals) ERC20(name, symbol) {        
        totalSupply = totalSupply**decimals;
        _mint(msg.sender, uint(totalSupply));
        //------------------launch Conbank Contract------------------
        CoinBank_Contract = new CoinBank(address(this),totalSupply);
    }
    //require coinbank 
    modifier CoinBankOnly{
        require(keccak256(abi.encodePacked(CoinBank_Contract)) == keccak256(abi.encodePacked(msg.sender)),"Only Contract coinbank can execute this function");
        _;
    }
    //Test logging and accounting user dividends
    function Register_Account() public returns(bool){
        require(accounts[msg.sender].exist == false,"user already exist");
        ledger[Account_Counter] = micro_ledger(msg.sender,true);
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
        uint dustSpread = value-totalAllocated;

        for(i;i<=Account_Counter;i++){
            (i,amountAllocated) = InternalAccounting(i,_singleShard);
            totalAllocated += amountAllocated;
            //refactor leftovers from unregisterd account & assimilate additional funds into treasury
            if(dustSpread<=dust_min){
                CoinBank_Interface(address(CoinBank_Contract)).Incomming_Payments{value:dustSpread}();
                i=i;
            }else if(i >= Account_Counter){
                i = i;
            }else{
                i = 0;
            }
            require(dustSpread>=dust_min); // if Dust Spread falls bellow dust min the loo ends
        }
           emit TreasuryClock(block.timestamp,true); 
    }
    function InternalAccounting(uint _shardHolder,uint _singleShard)internal returns(uint,uint){
        address Serach_result = ledger[Account_Counter].account;
        if(ledger[_shardHolder].exist == true && accounts[Serach_result].ammount > 0){
            accounts[Serach_result].ammount += balanceOf(ledger[Account_Counter].account) * _singleShard;
        }
        return (_shardHolder,accounts[Serach_result].ammount);      
    }
    //Redeem Dividends from treasury
    function Redeem()public returns(bool){
        address payable RedeemAddress = payable(msg.sender);
        require(accounts[RedeemAddress].exist == true,"User does not exist");
        RedeemAddress.transfer(accounts[msg.sender].ammount);
        accounts[msg.sender].ammount=0;
        return true;     
    }
    fallback() external payable {
        if(msg.value>0){
            payable(address(this)).transfer(msg.value);
        }
    }
    receive() external payable {

    }
}
