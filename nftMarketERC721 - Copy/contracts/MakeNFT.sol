// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MakeNFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenid;

    address private NftMarketAddress;

    event Mint(address owner, uint256 TokenID);

    constructor(address nftMarketA) ERC721("Farazaman", "FZM") {
        NftMarketAddress = nftMarketA;
    }

    function setToken(string memory tokenURI) public returns (uint256) {
        uint256 newTokenID = _tokenid.current();

        _safeMint(_msgSender(), newTokenID);
        _setTokenURI(newTokenID, tokenURI);
        setApprovalForAll(NftMarketAddress, true);
        _tokenid.increment();

        emit Mint(_msgSender(), newTokenID);

        return newTokenID;
    }
}
