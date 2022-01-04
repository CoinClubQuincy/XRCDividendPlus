pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//-------------------------- CoinBank Accounting Contract --------------------------
abstract contract CoinBank{
    uint coinbanktotal = address(this).balance;
    uint Shard_yeild_deposit; //votable
    uint supply;
    uint Fund_Retention_Rate; //votable
    address Treasury;
    uint totalBanks;
    // Keep track of Funds in CoinBank
    struct CoinBank_Accounting{
        uint Current_Funds_Retained;
        uint Previous_Time;
    }
    constructor(address _Treasury){
        Bank[0] = CoinBank_Accounting(0,block.timestamp);
        Treasury = _Treasury;
    }
    //CoinBank Index of all DAO Banks
    mapping (uint256 => CoinBank_Accounting) public Bank;

    // Send funds to Treasury Contract
    function Issue_To_Treasury(uint _single_Shard)internal{
       // send data through interface function
    }
    // Payments to CoinBank will take account of funds
    function Incomming_Payments()public payable{
        uint min=0;
        uint i=0;
        uint Total_from_Bank;

        for(i;i<=totalBanks;i++){
            Bank[totalBanks].Current_Funds_Retained += Total_from_Bank;
        }
        
        Total_from_Bank = address(this).balance-Total_from_Bank;
        if(block.timestamp>min+Bank[0].Previous_Time){
            uint single_Shard = uint(Total_from_Bank/supply);
            Issue_To_Treasury(single_Shard);
            //Call Accept from CoinBank
        }
    }
}
interface Accept_From_CoinBank_Interface {
    function Accept_From_CoinBank(uint _singleShard) external payable;
}
//-------------------------- Plus Treasury Contract --------------------------
abstract contract Plus is ERC20, CoinBank,Accept_From_CoinBank_Interface {
    uint counter =0;
    uint Account_Counter = 0;

    address public CoinBankAddress; // When coinbank is launched add address <--Here
    //mappings map Account amounts and micro ledger
    mapping (address => Accounts) public accounts;
    mapping (uint => micro_ledger) public ledger;
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
    constructor(string memory name,string memory symbol,uint totalSupply,uint Fund_Retention_Rate,uint totalBanks) ERC20(name, symbol) {
        _mint(msg.sender, uint(totalSupply));
        supply = uint(totalSupply);

        //launch Conbank Contract and store address as variable
        //CoinBankAddress = 
    }
    modifier CoinBankOnly{
        require(CoinBankAddress == msg.sender);
        _;
    }
    //Test logging and accounting user dividends
    function Add_to_Micro_ledger() internal{
        if(accounts[msg.sender].exist == true){
            //do nothing
        } else {
            ledger[Account_Counter] = micro_ledger(msg.sender,true);
            accounts[msg.sender] = Accounts(0,true);
            Account_Counter++;
        }
    }   
    //Account of your funds in contract
    function View_Account() public view returns(uint){
        if(accounts[msg.sender].exist == true){
            return accounts[msg.sender].ammount;
        } else {
            //event to register account
        }
    }
    //call contract balance
    function Balance() public returns (uint256) {
        return address(this).balance;
    }
    //Accept payment from CoinBank and issue dividends to accouts
    function Accept_From_CoinBank(uint _singleShard)external payable{
        uint i=0;
        for(i;i>=Account_Counter;i++){
            address Serach_result = ledger[Account_Counter].account;
            if(ledger[Account_Counter].exist == true && accounts[Serach_result].ammount > 0){
                //accounts[Serach_result].ammount += [balannceOf(ledger[Account_Counter].account) * _singleShard ];
            }
        }
    }
}