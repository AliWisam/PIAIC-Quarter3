// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, ERC721URIStorage, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    bool private saleStarted;
    uint256 private saleStartTime;
    uint256 private saleEndTime;
    uint256 private NFTPRice;
    
    constructor(uint256 _NFTPriceInWei) ERC721("MyToken", "MTK") {
        NFTPRice = _NFTPriceInWei;
    }
    
    modifier saleCheck{
        require(saleStarted == true,"");
        _;
    }
    
    //buy NFT
    function buyNFT() public payable returns(bool){
        require(msg.value ==NFTPRice ,"please buy with correct price");
        require(saleStarted == true && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime,"Sale not started yet or ended");
        
        safeMint(msg.sender,"https://floydnft.com/token/&quot");
        
        return true;
    }
    
    function getNFTPrice() public view returns(uint256){
        return NFTPRice;
    }
    
    function changePrice(uint256 _NFTPriceInWei) external onlyOwner returns(uint256){
        NFTPRice = _NFTPriceInWei;
        
        return NFTPRice;
        
    }
    
    function changeTokenURI(uint256 tokenId, string memory _tokenURI) public {
        _setTokenURI(tokenId,_tokenURI);
    }
    
    //setURI 
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal override(ERC721URIStorage){
        require(msg.sender == ownerOf(tokenId),"you are not owner of this token");
        super._setTokenURI(tokenId,_tokenURI);
    }
    
    
    function safeMint(address to, string memory _tokenURI) internal {
        
        _safeMint(to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), _tokenURI);
        _tokenIdCounter.increment();

    }
    
    
    function startSale() public returns(bool){
        saleStarted =  true;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + 30 days;
        return true;
    }
    function endSale() public returns(bool){
        saleStarted = false;
        return false;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    

}
