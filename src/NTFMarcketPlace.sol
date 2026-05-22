// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error NotPermitValue();

contract NFTMarketPlaceMultiCollection is Ownable {
    struct Listing {
        address seller;
        address nftAddress;
        uint16 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) listings;
    constructor() Ownable(msg.sender) {}
    modifier checkValue(uint256 value) {
        if (value <= 0) revert NotPermitValue();
        _;
    }
    // List NFT

    function listNFT(
        address nftAdress_,
        uint16 tokenId_,
        uint256 price_
    ) external checkValue(price_) {
        Listing memory listin = Listing({
            seller: msg.sender,
            nftAddress: nftAdress_,
            tokenId: tokenId_,
            price: price_
        });

        listings[nftAdress_][tokenId_] = listin;
    }
    // buy nft
    function buyNFT() external {}
    // Cancel
}
