pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract CoinBank{
    uint coinbanktotal = address(this).balance;
    uint Shard_yeild_depisit;
    uint supply;
    //function Add_To_Treasury(){}
}



contract Plus is ERC20, CoinBank {
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
    constructor(string memory name,string memory symbol,uint totalSupply) ERC20(name, symbol) {
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
    function View_CoinBank_Ammount() public view returns(uint){
        return accounts[msg.sender].ammount;
    }
    //call contract balance
    function Balance() public returns (uint256) {
        return address(this).balance;
    }
}
