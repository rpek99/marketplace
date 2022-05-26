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

    //TODO
    //function cancelListing() {}
    //function updateListing() {} maybe

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

    function getListings() external view returns (Listing[] memory) {
        Listing[] memory activeListings = new Listing[](
            totalListings.current()
        );

        for (uint256 i = 0; i < totalListings.current(); i++) {
            activeListings[i] = listings[i + 1];
        }

        return activeListings;
    }
}
