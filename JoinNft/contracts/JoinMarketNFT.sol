// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract JoinMarketNft is ReentrancyGuard, Context {
    using Counters for Counters.Counter;
    uint256 public marketplaceFee = 5;
    address private admin;
    struct MarketItem {
        address nftContract;
        uint256 tokenId;
        address payable owner;
        uint256 amountOfToken;
        uint256 price;
        bool sold;
    }
    struct AuctionData {
        uint256 _itemIds; //itemIds for itemToMarket
        uint256 percentOfThePrice; // Percentage discount for the price
        uint256 startTime;
        uint256 biddingEndTime;
        address highestBidder;
        uint256 highestBid;
    }
    struct Bid {
        address payable buyer;
        uint256 Price;
        uint256 time;
        bool isFinished;
    }

    mapping(uint256 => AuctionData) private itemAuctionData;
    Counters.Counter private itemIdsAuction;
    mapping(uint256 => Bid[]) bids;

    mapping(uint256 => MarketItem) private itemToMarket;
    Counters.Counter private itemIds;

    mapping(address => uint256) balances;

    event _createMarketItem(
        address nftContract,
        uint256 tokenId,
        address owner,
        uint256 amountOfToken,
        uint256 price,
        bool sold
    );

    event _deleteMarketItem(
        address nftContract,
        uint256 tokenId,
        address owner,
        uint256 amountOfToken
    );

    event _validateFixPrice(
        address nftContract,
        uint256 tokenId,
        address owner,
        address buyer,
        uint256 amountOfToken
    );

    event _createAuctionData(
        uint256 _itemIds,
        uint256 percentOfThePrice,
        uint256 startTime,
        uint256 biddingEndTime
    );

    event _addBidToNFT(
        uint256 itemIdsAuction,
        address buyer,
        uint256 Price,
        uint256 time
    );

    constructor() {
        admin = msg.sender;
    }

    function createMarketItem(
        address _nftContract,
        uint256 _tokenId,
        uint256 _amountOfToken,
        uint256 _price
    ) public nonReentrant {
        require(
            Address.isContract(_nftContract),
            "It is not a contract address"
        );
        require(
            _amountOfToken > 0,
            "The amount of tokens to sell, needs to be greater than 0"
        );
        require(
            _price > 0,
            "The full price for the tokens need to be greater than 0"
        );
        uint256 _itemId = itemIds.current();
        if (
            IERC165(_nftContract).supportsInterface(type(IERC721).interfaceId)
        ) {
            itemToMarket[_itemId] = MarketItem(
                _nftContract,
                _tokenId,
                payable(_msgSender()),
                1,
                _price,
                false
            );
            emit _createMarketItem(
                _nftContract,
                _tokenId,
                _msgSender(),
                1,
                _price,
                false
            );
        } else if (
            IERC165(_nftContract).supportsInterface(type(IERC1155).interfaceId)
        ) {
            itemToMarket[_itemId] = MarketItem(
                _nftContract,
                _tokenId,
                payable(_msgSender()),
                _amountOfToken,
                _price,
                false
            );
            emit _createMarketItem(
                _nftContract,
                _tokenId,
                _msgSender(),
                _amountOfToken,
                _price,
                false
            );
        }
        itemIds.increment();
    }

    function deleteMarketItem(uint256 _itemId) external {
        uint256 itemId = itemIds.current();
        require(_itemId < itemId, "createAuction: it is not item market");
        require(
            itemToMarket[_itemId].owner == _msgSender(),
            "delete: should be the owner."
        );
        require(itemToMarket[_itemId].sold != true, "delete: already sold.");
        delete itemToMarket[_itemId];
        emit _deleteMarketItem(
            itemToMarket[_itemId].nftContract,
            itemToMarket[_itemId].tokenId,
            itemToMarket[_itemId].owner,
            itemToMarket[_itemId].amountOfToken
        );
    }

    function validateFixPrice(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint256 _itemId = itemIds.current();
        require(itemId < _itemId, "createAuction: it is not item market");

        uint256 price = itemToMarket[itemId].price;
        uint256 feePrice = (price * marketplaceFee) / 100;
        uint256 tokenId = itemToMarket[itemId].tokenId;
        address _nftContract = itemToMarket[itemId].nftContract;

        require(msg.value == price, "Please Paye Correct Price");
        require(nftContract == _nftContract, "it is not smart contract");

        Address.sendValue(itemToMarket[itemId].owner, price - feePrice);
        if (
            IERC165(_nftContract).supportsInterface(type(IERC721).interfaceId)
        ) {
            IERC721(_nftContract).transferFrom(
                itemToMarket[itemId].owner,
                _msgSender(),
                tokenId
            );
            emit _validateFixPrice(
                _nftContract,
                tokenId,
                itemToMarket[itemId].owner,
                _msgSender(),
                1
            );
        } else if (
            IERC165(_nftContract).supportsInterface(type(IERC1155).interfaceId)
        ) {
            IERC1155(_nftContract).safeTransferFrom(
                itemToMarket[itemId].owner,
                msg.sender,
                itemToMarket[itemId].tokenId,
                itemToMarket[itemId].amountOfToken,
                "0x0"
            );
            emit _validateFixPrice(
                _nftContract,
                tokenId,
                itemToMarket[itemId].owner,
                _msgSender(),
                itemToMarket[itemId].amountOfToken
            );
        }
        itemToMarket[itemId].owner = payable(_msgSender());
        itemToMarket[itemId].sold = true;
        Address.sendValue(payable(admin), feePrice);
    }

    function checkBalanceERC20() public view returns (uint256) {
        return balances[_msgSender()];
    }

    function createAuctionData(
        uint256 itemIds_,
        uint256 _percentOfThePrice,
        uint256 _biddingTime
    ) public {
        uint256 _itemId = itemIds.current();
        require(itemIds_ < _itemId, "createAuction: it is not item market");
        MarketItem memory oneItem = itemToMarket[itemIds_];
        require(!oneItem.sold, "createAuction: already sold");
        require(
            _percentOfThePrice <= 100,
            "createAuction:The entered value must be less than or equal to 100"
        );
        require(
            _biddingTime > 1 days,
            "createAuction: The deadline should to be greater than 1 day"
        );

        uint256 Id = itemIdsAuction.current();
        uint256 minPrice = (oneItem.price * _percentOfThePrice) / 100;
        itemAuctionData[Id] = AuctionData({
            _itemIds: itemIds_,
            percentOfThePrice: minPrice,
            startTime: block.timestamp,
            biddingEndTime: block.timestamp + _biddingTime,
            highestBidder: address(0),
            highestBid: 0
        });
        itemIdsAuction.increment();
        emit _createAuctionData(
            itemIds_,
            minPrice,
            block.timestamp,
            block.timestamp + _biddingTime
        );
    }

    function addBidToNFT(uint256 _itemIdsAuction) public payable {
        uint256 itemIdsAuction_ = itemIdsAuction.current();
        require(
            _itemIdsAuction < itemIdsAuction_,
            "addBidToNFT : it is not item Auction"
        );
        AuctionData memory action = itemAuctionData[_itemIdsAuction];
        uint id_ = action._itemIds;
        MarketItem memory itemMarket = itemToMarket[id_];
        require(
            msg.sender != itemMarket.owner,
            "you cant bid on your own action"
        );
        require(
            msg.value >= action.percentOfThePrice,
            "this bid needs to be more than minBid"
        );
        require(
            action.biddingEndTime > block.timestamp,
            "this auction is ended"
        );
        if (bids[_itemIdsAuction].length > 0) {
            require(
                msg.value >
                    bids[_itemIdsAuction][bids[_itemIdsAuction].length - 1]
                        .Price,
                "this bid needs to be more than last bid"
            );
        }

        bids[_itemIdsAuction].push(
            Bid({
                Price: msg.value,
                buyer: payable(msg.sender),
                time: block.timestamp,
                isFinished: false
            })
        );
        balances[msg.sender] += msg.value;
        emit _addBidToNFT(
            _itemIdsAuction,
            msg.sender,
            msg.value,
            block.timestamp
        );
    }

    function acceptBidByOwner(uint256 _itemIdsAuction) public {
        uint256 itemIdsAuction_ = itemIdsAuction.current();
        require(
            _itemIdsAuction < itemIdsAuction_,
            "addBidToNFT : it is not item Auction"
        );

        if (bids[_itemIdsAuction].length > 0) {
            AuctionData storage action = itemAuctionData[_itemIdsAuction];
            uint id_ = action._itemIds;
            MarketItem storage itemMarket = itemToMarket[id_];
            Bid storage bid = bids[_itemIdsAuction][
                bids[_itemIdsAuction].length - 1
            ];
            Bid[] storage listBid = bids[_itemIdsAuction];

            require(msg.sender == itemMarket.owner, "you dont have permission");
            require(bid.isFinished == false, "the auction has ended");
            require(
                action.biddingEndTime < block.timestamp,
                "the bid has expired"
            );
            bid.isFinished = true;
            itemMarket.sold = true;
            uint payment = bid.Price;
            bid.Price = 0;
            balances[bid.buyer] -= payment;
            uint256 feePrice = (payment * marketplaceFee) / 100;
            Address.sendValue(itemMarket.owner, payment - feePrice);
            Address.sendValue(payable(admin), feePrice);
            for (uint i; i < listBid.length - 1; i++) {
                if (listBid[i].isFinished == false) {
                    payment = listBid[i].Price;
                    listBid[i].isFinished = true;
                    listBid[i].Price = 0;
                    balances[listBid[i].buyer] -= payment;
                    Address.sendValue(listBid[i].buyer, payment);
                }
            }
        } else {
            revert("There is no suggestion");
        }
    }
}
