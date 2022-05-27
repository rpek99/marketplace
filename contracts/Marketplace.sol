//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Marketplace {
    struct Listing {
        uint256 listingId;
        uint256 price;
        address payable owner;
        address assetContract;
        uint256 tokenId;
    }

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    address payable private owner;
    address payable private _governmentAccount;

    uint64 public governmentCommission = 2;
    uint64 public marketplaceCommission = 1;

    mapping(uint256 => Listing) public listings;
    Counters.Counter private totalListings;

    constructor(address governmentAccount) {
        owner = payable(msg.sender);
        _governmentAccount = payable(governmentAccount);
    }
    //create new listing
    function createListing(
        address assetContract,
        uint256 tokenId,
        uint256 price
    ) external {
        totalListings.increment();
        uint256 newListingId = totalListings.current();

        listings[newListingId] = Listing(
            newListingId,
            price,
            payable(msg.sender),
            assetContract,
            tokenId
        );

        IERC721(assetContract).transferFrom(msg.sender, address(this), tokenId);
    }

    // buy/sell listing
    function buy(uint256 listingId) external payable {
        require(msg.sender != address(0), "Address should not be 0");

        Listing memory listing = listings[listingId];
        uint256 marketplaceCommissionCalculated = listing
            .price
            .mul(marketplaceCommission)
            .div(100);
        uint256 governmentCommissionCalculated = listing
            .price
            .mul(governmentCommission)
            .div(100);
        uint256 requiredAmount = listing
            .price
            .add(marketplaceCommissionCalculated)
            .add(governmentCommissionCalculated);

        require(msg.value == requiredAmount, "Insufficent amount");

        //Commissions are paid
        _governmentAccount.transfer(governmentCommissionCalculated.mul(2));

        //Buyer pays marketplace commission
        owner.transfer(marketplaceCommissionCalculated);

        //Send money to the seller
        listing.owner.transfer(
            listing.price.sub(governmentCommissionCalculated)
        );

        IERC721(listing.assetContract).transferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );
    }

    // get all listings
    function getListings() external view returns (Listing[] memory) {
        Listing[] memory activeListings = new Listing[](
            totalListings.current()
        );

        for (uint256 i = 0; i < totalListings.current(); i++) {
            activeListings[i] = listings[i + 1];
        }

        return activeListings;
    }

    //get individual listings
    function getMyListings() public view returns (Listing[] memory) {
        uint256 totalListingCount = totalListings.current();
        uint256 listingCount = 0;
        uint256 currentIndex = 0;

        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].owner == msg.sender) {
                listingCount += 1;
            }
        } 
        Listing[] memory items = new Listing[](listingCount);
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[currentId];
                items[currentIndex] = currentListing;
                currentIndex += 1;
            }
        }

        return items;
    }

    // get specific listing 
    function getSpecificListing(uint256 listingId) public view returns (Listing memory){
        return listings[listingId];
    }

    //TODO
    //function updateListing() {} maybe
    //function removeListing() {} maybe
    //function addListing() {} maybe
}
