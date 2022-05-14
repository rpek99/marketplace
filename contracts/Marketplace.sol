//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace {
    struct Listing {
        uint256 listingId;
        uint256 price;
        address owner;
        address assetContract;
        uint256 tokenId;
    }

    using Counters for Counters.Counter;

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
            msg.sender,
            assetContract,
            tokenId
        );

        IERC721(assetContract).transferFrom(msg.sender, address(this), tokenId);
    }

    //TODO
    //function cancelListing() {}
    //function buy() {}
    //function updateListing() {} maybe

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
