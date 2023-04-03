//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract variable {
    using SafeMath for uint256;

    address private admin;

    uint256 public marketplaceFee = 5;

    mapping(uint => address) public recipient;
    mapping(uint => uint) public fee;
    uint256 public recipientCount;

    mapping(uint => SellList) public sales;
    uint256 public salesId;

    mapping(uint => mapping(uint => OfferData)) public offerInfo;
    mapping(uint => uint) public offerCount;

    mapping(address => uint) public escrowAmount;

    mapping(uint => AuctionData) public auction;
    uint256 public auctionId;

    /// @notice This is the Sell struct, the basic structures contain the owner of the selling tokens.
    struct SellList {
        address seller;
        address token;
        uint256 tokenId;
        uint256 amountOfToken;
        uint256 deadline;
        uint256 price;
        bool isSold;
    }

    struct OfferData {
        address offerAddress;
        uint256 offerPrice;
        bool isAccepted;
    }

    struct AuctionData {
        address creator;
        address token;
        address highestBidder;
        uint256 tokenId;
        uint256 amountOfToken;
        uint256 highestBid;
        uint256 startPrice;
        uint256 minIncrement;
        uint256 startDate;
        uint256 duration;
        Action action;
    }

    enum Action {
        RESERVED,
        STARTED
    }
}
