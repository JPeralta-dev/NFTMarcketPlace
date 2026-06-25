// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import {Test} from "lib/forge-std/src/Test.sol"; 
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {NFTMarketPlaceMultiCollection} from "../src/NTFMarcketPlace.sol";

contract MockNFT is ERC721{

    constructor() ERC721("MockNFT","MNFT") {}
    

    function mint(address to_, uint256 tokenId_)external{  
        _mint(to_, tokenId_);
    }
}


contract NtfMarcketPlaceTest is Test {

    NFTMarketPlaceMultiCollection nftMarket;
    MockNFT nft;
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    uint256 tokenId_ = 0;


    function setUp() public{
        vm.startPrank(deployer);
        nftMarket = new NFTMarketPlaceMultiCollection();
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(user);
        nft.mint(user, tokenId_);
        vm.stopPrank();
    }
    
    function testMintNft () public view {
        address ownerOf_ = nft.ownerOf(tokenId_);
        assert(ownerOf_ == user);
    }
}