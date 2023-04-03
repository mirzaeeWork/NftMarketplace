const hre = require("hardhat");

async function main() {
  const Market = await hre.ethers.getContractFactory("NFTMarket");
  const market = await Market.deploy();

  await market.deployed();

  const NFT = await hre.ethers.getContractFactory("MakeNFT");
  const nft = await NFT.deploy(market.address);

  await nft.deployed();


  console.log(`Market deployed to : ${market.address}`);
  console.log(`Nft deployed to : ${nft.address}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
