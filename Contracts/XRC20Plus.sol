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
    function Submit(address _reciver,uint _amount) public{}   
    //Account of your funds in contract
    function CoinBank() public view returns(string memory){
        return accounts[msg.sender].ammount;
    }

    //call contract balance
    function Balance() public returns (uint256) {
        return address(this).balance;
    }
}