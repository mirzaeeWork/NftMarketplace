// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

contract variable {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemISold;

    address private owner;
    uint256 private listingPrice = 0.01 ether;


    struct MarketItem {
        uint256 itemId; 
        uint256 tokenId;
        uint256 price;
        address nftContract;
        address payable seller;
        address payable owner;
        string itemName;
        string itemDescription;
        string tokenURI;
        bool sold;
    }

    mapping(uint256 => MarketItem) private itemToMarket;
}
