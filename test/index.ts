import { expect } from "chai";
import { ethers } from "hardhat";
import { Marketplace, NFT } from "../typechain";

describe("Marketplace", function () {
  it("Should create a new listing", async function () {
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = (await Marketplace.deploy(
      "0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097"
    )) as Marketplace;
    await marketplace.deployed();

    const NFT = await ethers.getContractFactory("NFT");
    const nft = (await NFT.deploy(marketplace.address)) as NFT;
    await nft.deployed();

    let tx = await nft.mint("jkhgkjhgkjhgj");
    await tx.wait();

    tx = await marketplace.createListing(
      nft.address,
      1,
      ethers.utils.parseUnits("1", "ether")
    );

    await tx.wait();

    const allListings = await marketplace.getListings();

    console.log(allListings);
    expect(allListings.length).to.be.equal(1);
  });
});
