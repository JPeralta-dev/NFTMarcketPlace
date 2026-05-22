// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

error NotPermitValue();

contract NFTMarketPlaceMultiCollection is Ownable {
    struct Listing {
        address seller;
        address nftAddress;
        uint16 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) listings;

    event addListingNft(address indexed nftAdress, address indexed seller, uint16 tokenId, uint256 price);
    event cancelledNFT(address indexed nftAdress, address indexed selle, uint16 tokenId);
    constructor() Ownable(msg.sender) {}

    modifier checkValue(uint256 value) {
        _checkValue(value);
        _;
    }

    function _checkValue(uint256 value) internal pure {
        if (value <= 0) revert NotPermitValue();
    }

    // List NFT

    function listNft(address nftAdress_, uint16 tokenId_, uint256 price_) external checkValue(price_) {
        // necesitamos evaluar que si sea un token como hacemos eso
        address owner_ = IERC721(nftAdress_).ownerOf(tokenId_);

        require(owner_ == msg.sender, "You are not the owner of the NFT");

        Listing memory listin = Listing({seller: msg.sender, nftAddress: nftAdress_, tokenId: tokenId_, price: price_});

        listings[nftAdress_][tokenId_] = listin;
        emit addListingNft(nftAdress_, msg.sender, tokenId_, price_);
    }
    // buy nft
    function buyNft() external {}
    // Cancel

    function cancelNft(address nftAdress_, uint16 tokenId_) external {
        Listing memory listing_ = listings[nftAdress_][tokenId_];

        require(listing_.seller == msg.sender, "Tu no eres el dueno");

        delete listings[nftAdress_][tokenId_];
        emit cancelledNFT(nftAdress_, msg.sender, tokenId_);
    }
}
