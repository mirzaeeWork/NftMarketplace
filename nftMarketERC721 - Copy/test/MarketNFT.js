const { expect } = require("chai");

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");

describe("Market", function () {
  async function deployTwoContract() {
    const Market = await hre.ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
  
    await market.deployed();
  
    const NFT = await hre.ethers.getContractFactory("MakeNFT");
    const nft = await NFT.deploy(market.address);
  
    await nft.deployed();
  
  
    console.log(`Market deployed to : ${market.address}`);
    console.log(`Nft deployed to : ${nft.address}`);
    
  
    const [addr1, addr2] = await ethers.getSigners();
    return { market,nft, addr1, addr2 };
  }

  it("should be able to mint and burn", async function () {
    console.log('------------------------------------------')

    const {market,nft, addr1, addr2 } = await loadFixture(deployTwoContract);


    await nft.setToken('http://www.mytokenlocation.com')
    await nft.setToken('http://www.mytokenlocation.com')

    await market.mintNFT(nft.address,0,ethers.utils.parseEther("10"))
    await market.mintNFT(nft.address,1,ethers.utils.parseEther("100"))

    await market.connect(addr2).buyNft(nft.address,0,{value:ethers.utils.parseEther("10")})

    const items=await market.ShowMarketItem()

    expect(items.length).to.equal(2)
  });
});