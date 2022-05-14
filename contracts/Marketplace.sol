//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/Counters.sol";

contract Market {
    
    struct Listing{
        uint256 listingId;
        uint256 price;
        address owner;
        address assetContract;
        uint256 tokenId;
    }



    address payable owner;
    address payable _governmentAccount;

    uint64 governmentCommission = 2;
    uint64 marketplaceCommission = 1;

    mapping(uint256 => Listing) public listings;
    uint public totalListings;

    constructor(address governmentAccount) {
        owner = payable(msg.sender);
        _governmentAccount = payable(governmentAccount);
    }

    function createListing(address assetContract, uint256 tokenId, uint256 price) external {


    }


}
