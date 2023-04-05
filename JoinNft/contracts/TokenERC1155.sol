// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TokenERC1155 is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public name;
    string public symbol;

    mapping(uint256 => string) public tokenURI;

    constructor() ERC1155("") {
        name = "mirzaee";
        symbol = "MIZ";
    }

    function mint(
        string memory _tokenURI,
        address account,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(account, tokenId, amount, data);
        setURI(tokenId, _tokenURI);
    }

    function burn(uint256 _id, uint256 _amount) external {
        _burn(msg.sender, _id, _amount);
    }

    function setURI(uint256 _id, string memory _uri) internal onlyOwner {
        tokenURI[_id] = _uri;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURI[_id];
    }

    function getTokenIdCounter() public view returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId - 1;
    }
}