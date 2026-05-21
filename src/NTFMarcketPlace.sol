// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract NFTMarketPlaceMultiCollection is Ownable {
    struct Listing {
        address seller;
        address nftAddress;
        uint16 tokenId;
        uint256 price;
    }

    mapping(address => Listing) test;

    constructor() Ownable(msg.sender) {}
    // List NFT

    // buy nft
    // Cancel
}
