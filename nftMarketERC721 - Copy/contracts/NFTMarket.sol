// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTMarket is ReentrancyGuard, Context {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemISold;

    address private owner;
    uint256 private listingPrice = 0.01 ether;

    constructor() {
        owner = payable(_msgSender());
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private itemToMarket;

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getItems(uint256 id) public view returns (MarketItem memory) {
        return itemToMarket[id];
    }

    function mintNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public  nonReentrant {
        require(price > 0, "Price Must be Bigger 0");

        uint256 itemId = _itemIds.current();
        itemToMarket[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(_msgSender()),
            price,
            true
        );
        _itemIds.increment();
    }

    function buyNft(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint256 price = itemToMarket[itemId].price;
        uint256 tokenId = itemToMarket[itemId].tokenId;

        require(msg.value == price, "Please Paye Correct Price");

        Address.sendValue(itemToMarket[itemId].owner, msg.value - listingPrice);
        IERC721(nftContract).transferFrom(
            itemToMarket[itemId].owner,
            _msgSender(),
            tokenId
        );
        itemToMarket[itemId].owner = payable(_msgSender());
        itemToMarket[itemId].sold = false;
        _itemISold.increment();
        Address.sendValue(payable(owner), listingPrice);
    }

    function listForSale(uint256 itemId) public {
        itemToMarket[itemId].sold = true;
    }

    function ShowMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (itemToMarket[i].sold) {
                items[currentIndex] = itemToMarket[i];
                currentIndex += 1;
            }
        }
        return items;
    }

    function ShowMyNFTMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = 0;
        uint256 totalItem = _itemIds.current();
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItem; i++) {
            if (itemToMarket[i].owner == _msgSender()) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItem; i++) {
            if (itemToMarket[i].owner == _msgSender()) {
                uint currentId = itemToMarket[i].itemId;
                MarketItem storage currentItem = itemToMarket[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

} 
