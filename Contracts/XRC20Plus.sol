pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//-------------------------- CoinBank Accounting Contract --------------------------
interface CoinBank_Interface{
    function Incomming_Payments()external payable;
}
contract CoinBank is CoinBank_Interface{
    uint TotalCoinbanks;
    uint Shard_yeild_deposit; 
    uint Supply;
    uint Fund_Retention_Rate; 
    address Treasury;
    uint totalBanks;
    // Keep track of Funds in CoinBank
    struct CoinBank_Accounting{
        uint Current_Funds_Retained;
        uint Previous_Time;
    }
    constructor(address _Treasury,uint _totalBanks,uint _supply){
        Bank[0] = CoinBank_Accounting(0,block.timestamp);
        Treasury = _Treasury;
        TotalCoinbanks = _totalBanks;
        Supply = _supply;
    }
    //CoinBank Index of all DAO Banks
    mapping (uint256 => CoinBank_Accounting) public Bank;

    // Send funds to Treasury Contract
    function Issue_To_Treasury(uint _single_Shard)internal{
       // send data through interface function
        Plus_Interface exeInterface = Plus_Interface(Treasury); //place treasury contract address here
        exeInterface.Accept_From_CoinBank(_single_Shard);      
    }
    // Payments to CoinBank will take account of funds
    function Incomming_Payments()public payable{
        uint min=0; // add one min to the int
        uint i=0;
        uint Total_from_Bank =0;

        for(i;i<=totalBanks;i++){
            Bank[totalBanks].Current_Funds_Retained += Total_from_Bank;
        }
        
        Total_from_Bank = address(this).balance-Total_from_Bank;
        if(block.timestamp>min+Bank[0].Previous_Time){
            uint single_Shard = uint(Total_from_Bank/Supply);
            Issue_To_Treasury(single_Shard); //Call Accept from CoinBank
        }
    }
}
interface Plus_Interface {
    function View_Account() external view returns(bool);
    function Balance() external view returns(uint256);
    function Accept_From_CoinBank(uint)external payable;
    function Redeem()external returns(bool);
    function Register_Account() external;
}
//-------------------------- Plus Treasury Contract --------------------------
abstract contract Plus is ERC20, CoinBank,Plus_Interface {
    uint counter =0;
    uint Account_Counter = 0;
    uint dust_min = 100; //min amount of dust allowed in treasury per refreash

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
    constructor(string memory name,string memory symbol,uint totalSupply,uint totalBanks,uint8 decimals) ERC20(name, symbol) {        
        totalSupply = totalSupply**decimals;
        _mint(msg.sender, uint(totalSupply));

        //------------------launch Conbank Contract------------------
        CoinBank_Contract = new CoinBank(address(this),totalBanks,totalSupply);
    }
    //require coinbank 
    modifier CoinBankOnly{
        require(keccak256(abi.encodePacked(CoinBank_Contract)) == keccak256(abi.encodePacked(msg.sender)),"Only Contract coinbanks can execute this function");
        _;
    }
    //Test logging and accounting user dividends
    function Register_Account() public{
        if(accounts[msg.sender].exist == true){
            //do nothing Event
            //already registerd
        } else {
            ledger[Account_Counter] = micro_ledger(msg.sender,true);
            accounts[msg.sender] = Accounts(0,true);
            Account_Counter++;
            //account registerd event
        }
    }   
    //Account of your funds in contract
    function View_Account() public view returns(bool){
        if(accounts[msg.sender].exist == true){
            accounts[msg.sender].ammount;
            return true;
        }else{
            return false;
        }
    }
    //call contract balance
    function Balance() public view returns(uint256) {
        return address(this).balance;
    }
    //Accept payment from CoinBank and issue dividends to accouts
    function Accept_From_CoinBank(uint _singleShard)public payable CoinBankOnly{
        uint value = msg.value;
        uint ShardCounter=0;
        uint i=0;
        for(i;i>=Account_Counter;i++){
            address Serach_result = ledger[Account_Counter].account;
            if(ledger[Account_Counter].exist == true && accounts[Serach_result].ammount > 0){
                accounts[Serach_result].ammount += balanceOf(ledger[Account_Counter].account) * _singleShard;
                ShardCounter += balanceOf(ledger[Account_Counter].account) * _singleShard;
            }
        }
        //refactor leftovers from unregisterd account & assimilate additional funds into treasury
        if(ShardCounter != value && value<=dust_min){
            uint leftovers = value - ShardCounter;
            Accept_From_CoinBank(leftovers);
        }
    }
    //Redeem Dividends from treasury
    function Redeem()public returns(bool){
        address payable RedeemAddress = payable(msg.sender);
        if(accounts[RedeemAddress].exist == true){
            RedeemAddress.transfer(accounts[msg.sender].ammount);
            accounts[msg.sender].ammount=0;
            return true;
        } else {
            return false;
            //no account registerd Event
        }      
    }
}
