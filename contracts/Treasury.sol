pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Treasury_Interface {
    function View_Account() external view returns(uint);
    function Redeem()external returns(bool);
    function Register_Account()external returns(bool);
    function CountRegisterdShards()external returns(uint);
}

/// @title XRC-20 token that pays dividends to its holders
/// @notice Every payment to this contract is shared across all holders by balance. Nobody has
/// to register, and no payment loops over holders. Each payment raises a running total of what
/// one token has earned. When a balance is about to change, the holder's earnings so far are
/// recorded first, so dividends stay with whoever held the tokens at the time.
contract Treasury is ERC20, Treasury_Interface {
    //Lets the running total keep fractions of a wei
    uint private constant MAGNITUDE = 2**128;

    uint8 private immutable tokenDecimals;
    //Total of all payments received
    uint public totalAllocated=0;
    //Running total of what one token unit has earned, scaled by MAGNITUDE
    uint public magnifiedPerShare=0;
    //Part of past payments too small to split yet, scaled by MAGNITUDE
    uint private carriedRemainder=0;
    //Earnings recorded for each account and not yet redeemed, scaled by MAGNITUDE
    mapping (address => uint) private magnifiedCredit;
    //Value of the running total when each account was last recorded
    mapping (address => uint) private lastPerShare;

    //launch Contract
    constructor(string memory name,string memory symbol,uint totalSupply,uint8 decimals) ERC20(name, symbol) {
        require(totalSupply > 0, "supply is required");
        tokenDecimals = decimals;
        _mint(msg.sender, totalSupply*(10**decimals));
    }
    function decimals() public view override returns(uint8){
        return tokenDecimals;
    }
    //Kept for older callers. Every holder now earns without registering.
    function Register_Account() public pure returns(bool){
        return true;
    }
    //Account of your funds in contract
    function View_Account() public view returns(uint){
        return (magnifiedCredit[msg.sender] + pendingFor(msg.sender)) / MAGNITUDE;
    }
    //Counts all the tokens that earn dividends
    function CountRegisterdShards() public view returns(uint){
        return totalSupply();
    }
    function pendingFor(address _account) internal view returns(uint){
        return balanceOf(_account) * (magnifiedPerShare - lastPerShare[_account]);
    }
    function settle(address _account) internal{
        magnifiedCredit[_account] += pendingFor(_account);
        lastPerShare[_account] = magnifiedPerShare;
    }
    //Records earnings at the old balance before any transfer changes it
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override{
        super._beforeTokenTransfer(from, to, amount);
        if(from != address(0)){
            settle(from);
        }
        if(to != address(0)){
            settle(to);
        }
    }
    //Redeem Dividends from treasury
    function Redeem()public returns(bool){
        settle(msg.sender);
        uint redeemValue = magnifiedCredit[msg.sender] / MAGNITUDE;
        require(redeemValue > 0, "account value 0");
        magnifiedCredit[msg.sender] -= redeemValue * MAGNITUDE;
        (bool success, ) = payable(msg.sender).call{value: redeemValue}("");
        require(success, "payment failed");
        return true;
    }
    //Payments made to the contract
    receive() external payable {
        totalAllocated += msg.value;
        uint magnified = msg.value * MAGNITUDE + carriedRemainder;
        magnifiedPerShare += magnified / totalSupply();
        carriedRemainder = magnified % totalSupply();
    }
}
