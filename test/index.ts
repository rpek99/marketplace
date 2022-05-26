import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { Marketplace, NFT } from "../typechain";

let marketplace: Marketplace;
let nft: NFT;
let owner: SignerWithAddress;
let seller: SignerWithAddress;
let buyer: SignerWithAddress;

describe("Marketplace", function () {
  beforeEach(async function () {
    [owner, seller, buyer] = await ethers.getSigners();
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = (await Marketplace.connect(owner).deploy(
      "0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097"
    )) as Marketplace;
    await marketplace.deployed();

    const NFT = await ethers.getContractFactory("NFT");
    nft = (await NFT.connect(owner).deploy(marketplace.address)) as NFT;
    await nft.deployed();
  });

  it("Should create a new listing", async function () {
    let tx = await nft.mint("jkhgkjhgkjhgj");
    await tx.wait();

    tx = await marketplace.createListing(
      nft.address,
      1,
      ethers.utils.parseUnits("1", "ether")
    );

    await tx.wait();

    const allListings = await marketplace.getListings();
    expect(allListings.length).to.be.equal(1);
  });

  it("Should transfer nft to buyer after the sale", async function () {
    let tx = await nft.connect(seller).mint("jkhgkjhgkjhgj");
    await tx.wait();

    tx = await marketplace
      .connect(seller)
      .createListing(nft.address, 1, ethers.utils.parseUnits("1", "ether"));
    await tx.wait();

    tx = await marketplace
      .connect(buyer)
      .buy(1, { value: ethers.utils.parseUnits("1.03", "ether") });

    await tx.wait();

    let balance = await nft.balanceOf(buyer.address);
    expect(balance).to.be.equal(BigNumber.from(1));

    balance = await nft.balanceOf(marketplace.address);
    expect(balance).to.be.equal(BigNumber.from(0));

    balance = await nft.balanceOf(seller.address);
    expect(balance).to.be.equal(BigNumber.from(0));
  });
});
