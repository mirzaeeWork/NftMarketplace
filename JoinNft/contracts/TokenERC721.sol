// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8

contract TokenERC721 is ERC721URIStorage{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(string memory tokenURI) public  returns (uint256){
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(_msgSender(), tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenIdCounter.increment();
        return tokenId;
    }
}
