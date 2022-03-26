import { ethers } from "hardhat";

async function DeployBAT() {
  // deploting the Bored ape tokens
  const BAToken = await ethers.getContractFactory("BoredApeTokens");
  const BAT = await BAToken.deploy();

  await BAT.deployed();
  console.log("BAToken", BAT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
DeployBAT().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});