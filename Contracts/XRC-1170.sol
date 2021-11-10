// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/XRC1155/XRC1155.sol";


contract XRC1170 is XRC1155 {
    uint256 public constant SHARDS = 0;
    string public Name;
    uint counter =0;
    uint total_supply;

    mapping (uint256 => Micro_Ledger) public Micro_ledger_map;
    
    struct Micro_Ledger{
        address payable Address;
    }
    
    constructor(string memory _name,uint _Shards, string memory _uri) public XRC1155(_uri) {
        Name = _name;
        total_supply = _Shards;
        
        _mint(msg.sender, SHARDS, _Shards, "");
        Ledger(msg.sender);
    }

    function Ledger(address payable _to) public{
        uint i=0;
        for(i;i<=counter;i++){
            if(Micro_ledger_map[i] != Micro_Ledger(_to) && counter ==i){
                Micro_ledger_map[i++] = Micro_Ledger(_to);
                counter++;
            }
        }
    }

    function Submit(address payable _address, uint _total) public payable{
        _address.send(_total);
        Ledger(_address);
    }
    
    function Dividends() public payable{
        uint i=0;
        uint ammount = total_supply/address(this).balance;
        for (i;i<=counter;i++){
            address payable Pay = Micro_ledger_map[i].Address;
            if(balanceOf(Micro_ledger_map[i].Address,0) != 0){
                uint total = ammount * balanceOf(Micro_ledger_map[i].Address,0);
                Submit(Pay,total);
            }
        }
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
    }
}