pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract CoinBank{
    uint coinbanktotal = address(this).balance;
    uint Shard_yeild_deposit;
    uint supply;
    uint Fund_Retention_Rate;
    address Treasury;
    // Keep track of Funds in CoinBank
    struct CoinBank_Accounting{
        uint Current_Funds_Retained;
        uint Current_Time;
    }
    constructor(address _Treasury){
        Bank[0] = CoinBank_Accounting(0,block.timestamp);
        Treasury = _Treasury;
    }
    //CoinBank Index of all DAO Banks
    mapping (uint256 => CoinBank_Accounting) public Bank;

    // Send funds to Treasury Contract
    function Issue_To_Treasury(address payable _TreasuryContract)internal{
        _TreasuryContract.transfer(address(this).balance);
    }
    // Payments to CoinBank will take account of funds
    function Incomming_Payments()public payable{
        uint min=0;
        if(min+block.timestamp>Bank[0].Current_Time){
            Issue_To_Treasury(payable(Treasury));
            //Call Accept from CoinBank
        }
    }
}
//----------------------------------------------------------------------------------------------------------------
abstract contract Plus is ERC20, CoinBank {
    uint counter =0;
    uint Account_Counter = 0;

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
    }
    //launch Contract
    constructor(string memory name,string memory symbol,uint totalSupply,uint Fund_Retention_Rate) ERC20(name, symbol) {
        _mint(msg.sender, uint(totalSupply));
        supply = uint(totalSupply);

    }
    //Test logging and accounting user dividends
    function Add_to_Micro_ledger() internal{
        if(accounts[msg.sender].exist == true){
            //do nothing
        } else {
            ledger[Account_Counter] = micro_ledger(msg.sender);
            accounts[msg.sender] = Accounts(0,true);
            Account_Counter++;
        }
    }   
    //Account of your funds in contract
    function View_Account() public view returns(uint){
        return accounts[msg.sender].ammount;
    }
    //call contract balance
    function Balance() public returns (uint256) {
        return address(this).balance;
    }
    //function Dividends(){//Run Dividends Accounting matt} 

    //Accept payment from CoinBank and issue dividends to accouts
    function Accept_From_CoinBank(uint _Total_from_Bank)external {
        //uint single_Shard = (_Total_from_Bank/totalSupply);
        uint i=0;
        
        //Dividends()
    }
}
