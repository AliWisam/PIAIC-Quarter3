// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20, Ownable {
    using SafeMath for uint256;
    uint256 price; // the price, in wei, per token
    constructor(uint256 _price) ERC20("MyToken", "MTK") {
        price = _price;
    }
    function buyTokens() public payable{
        uint256 scaledAmount = msg.value.mul(10 ** decimals()).div(price);
        _mint(msg.sender, scaledAmount);
        
    }
    
    function setPrice(uint256 _price) public onlyOwner returns(uint256){
        price = _price;
        return price;
    }
     // This function is called for all messages sent to
    // this contract, except plain Ether transfers
    // (there is no other function except the receive function).
    // Any call with non-empty calldata to this contract will execute
    // the fallback function (even if Ether is sent along with the call).
    fallback() external payable {
        
        buyTokens();
        
    }
    
    // This function is called for plain Ether transfers, i.e.
    // for every call with empty calldata.
    receive() external payable { }
    
    
    //anyone can also direct buy tokens
    // function buy(uint256 numberOfTokens) public payable onlyOwner {
    //     require(msg.value == numberOfTokens.mul(price));
    //     uint256 scaledAmount = numberOfTokens.mul(uint256(10) ** decimals());
    //     _mint(msg.sender, scaledAmount);
    // }
}
