pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Plus is ERC20 {
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
    constructor(string memory name,string memory symbol,uint256 totalSupply) ERC20(name, symbol) {
        _mint(msg.sender, uint(totalSupply));
    }
    //Test logging and accounting user dividends
    function Submit(address _reciver,uint _amount) public{

        if(accounts[_reciver].exist == true){
            if(accounts[_reciver].ammount > 0){
                Add = _amount + accounts[_reciver].ammount
                accounts[msg.sender] = Accounts(Add,true);
            }
        } else {
            micro_ledger[Account_Counter] = micro_ledger(msg.sender);
            accounts[msg.sender] = Accounts(msg.value,true);
        }
        Plus.transfer(_reciver,_amount);
    }   
    //Account of all funds in contract
    function CoinBank() public payable{}
    //call contract balance
    function Balance() public returns (uint256) {
        return address(this).balance;
    }
}