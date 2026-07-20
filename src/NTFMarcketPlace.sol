// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

error NotPermitValue();
error NotApproved();

contract NFTMarketPlaceMultiCollection is Ownable, ReentrancyGuard {
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event addListingNft(address indexed nftAdress, address indexed seller, uint256 tokenId, uint256 price);
    event cancelledNFT(address indexed nftAdress, address indexed seller, uint256 tokenId);
    event soldNft(address indexed nftAdress, address indexed seller, uint256 tokenId, address indexed comprador);
    constructor() Ownable(msg.sender) {}

    modifier checkValue(uint256 value) {
        _checkValue(value);
        _;
    }

    // List NFT

    function listNft(address nftAdress_, uint256 tokenId_, uint256 price_) external checkValue(price_) {
        // necesitamos evaluar que si sea un token como hacemos eso
        address owner_ = checkOwnerNft(nftAdress_,tokenId_,msg.sender);

        checkApproveToken(nftAdress_, tokenId_, owner_);

        Listing memory listin = Listing({seller: msg.sender, nftAddress: nftAdress_, tokenId: tokenId_, price: price_}); // gasta poco gas porquie se gaurda en memora una vez termien no queda en la red

        listings[nftAdress_][tokenId_] = listin;
        emit addListingNft(nftAdress_, msg.sender, tokenId_, price_);
    }

    // buy nft
    function buyNft(address nftAdress_, uint16 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listings[nftAdress_][tokenId_];
        require(listing_.price > 0, "Listing not exist");
        require(msg.value == listing_.price, "Incorrect value");

        checkOwnerNft(nftAdress_, tokenId_, listing_.seller);

        checkApproveToken(nftAdress_, tokenId_, listing_.seller);

        delete listings[nftAdress_][tokenId_]; // primer cambio el estado

        (bool success,) = listing_.seller.call{value: msg.value}(""); // envio al vendedor su parte

        require(success, "Fail");

        IERC721(nftAdress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId); // transferir el nft

        emit soldNft(listing_.nftAddress, listing_.seller, listing_.tokenId, msg.sender);
    }
    // Cancel

    function cancelNft(address nftAdress_, uint16 tokenId_) external {
        Listing memory listing_ = listings[nftAdress_][tokenId_];

        require(listing_.seller == msg.sender, "Tu no eres el dueno");

        delete listings[nftAdress_][tokenId_];
        emit cancelledNFT(nftAdress_, msg.sender, tokenId_);
    }

    function _checkValue(uint256 value) internal pure {
        if (value <= 0) revert NotPermitValue();
    }

    function checkApproveToken(address nftAdress_, uint256 tokenId_, address seller_) internal view {
        bool approved = IERC721(nftAdress_).getApproved(tokenId_) == address(this)
            || IERC721(nftAdress_).isApprovedForAll(seller_, address(this));
        if (!approved) revert NotApproved();
    }

    function checkOwnerNft(address nftAdress_, uint256 tokenId_,address shoulOwner_) internal view returns (address owner_)  {
        IERC721(nftAdress_).ownerOf(tokenId_);
        require(owner_ == shoulOwner_, "You are not the owner of the NFT");
        return owner_;
    }
}
