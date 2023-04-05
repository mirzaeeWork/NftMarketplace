const hre = require("hardhat");

async function main() {
  const ERC1155 = await hre.ethers.getContractFactory("TokenERC1155");
  const erc1155 = await ERC1155.deploy();

  await erc1155.deployed();

  const ERC721 = await hre.ethers.getContractFactory("TokenERC721");
  const erc721 = await ERC721.deploy();

  await erc721.deployed();

  const MarketNft = await hre.ethers.getContractFactory("JoinMarketNft");
  const marketNft = await MarketNft.deploy();

  await marketNft.deployed();



  console.log(
    `erc721 deployed to : ${erc721.address}`
  );
  console.log(
    `erc1155 deployed to : ${erc1155.address}`
  );
  console.log(
    `marketNft deployed to : ${marketNft.address}`
  );


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
