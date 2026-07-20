// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import {Test} from "lib/forge-std/src/Test.sol";
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {NFTMarketPlaceMultiCollection} from "../src/NTFMarcketPlace.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract NtfMarcketPlaceTest is Test {
    NFTMarketPlaceMultiCollection nftMarket;
    MockNFT nft;
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    uint256 priceBased_ = 1e18;
    uint16 tokenId_ = 0;

    function setUp() public {
        vm.startPrank(deployer);
        nftMarket = new NFTMarketPlaceMultiCollection();
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(user);
        nft.mint(user, tokenId_);
        vm.stopPrank();
    }

    function testMintNft() public view {
        address ownerOf_ = nft.ownerOf(tokenId_);
        assert(ownerOf_ == user);
    }

    function testSholdRevertIfPriceZero() public {
        vm.startPrank(user);

        vm.expectRevert();
        nftMarket.listNft(address(nft), tokenId_, 0);

        vm.stopPrank();
    }

    function testShoultRevertIdNotOwner() public {
        vm.startPrank(vm.addr(3));

        vm.expectRevert("You are not the owner of the NFT");
        nftMarket.listNft(address(nft), tokenId_, 4);

        vm.stopPrank();
    }

    function testListingCorrectly() public {
        vm.startPrank(user);

        (address sellerBefore,,,) = nftMarket.listings(address(nft), tokenId_);

        nftMarket.listNft(address(nft), tokenId_, priceBased_);

        (address sellerAfter,,,) = nftMarket.listings(address(nft), tokenId_);

        assert(sellerAfter == user && sellerBefore == address(0));

        vm.stopPrank();
    }

    function testListShouldRevertIfNotOwner() public {
        vm.startPrank(user);

        (address sellerBefore,,,) = nftMarket.listings(address(nft), tokenId_);

        nftMarket.listNft(address(nft), tokenId_, priceBased_);

        (address sellerAfter,,,) = nftMarket.listings(address(nft), tokenId_);

        assert(sellerAfter == user && sellerBefore == address(0));

        vm.stopPrank();

        address user2 = vm.addr(3);

        vm.startPrank(user2);
        vm.expectRevert("Tu no eres el dueno");
        nftMarket.cancelNft(address(nft), tokenId_);

        vm.stopPrank();
    }

    function testCancelList() {
        
    }
}
