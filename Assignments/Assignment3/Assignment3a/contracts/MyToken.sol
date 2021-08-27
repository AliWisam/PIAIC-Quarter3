// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract MyToken is ERC20Capped, Ownable {
    
    // timestamp when token release is enabled
    uint256 private immutable _releaseTime;
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 cap
        )
    ERC20(name, symbol) 
    ERC20Capped(cap)
    {
        _releaseTime = block.timestamp + 30 days;
        
    }
    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }
    function mint(uint256 _amount) public {
        _mint(owner(), _amount);
    }
    
    function transfer(address recepient, uint256 amount) public override returns (bool){
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");
        super._transfer(msg.sender,recepient,amount);
        return true;
    }
    
        function transferFrom(address sender,address recepient, uint256 amount) public override returns (bool){
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");
        super._transfer(sender,recepient,amount);
        return true;
    }
}