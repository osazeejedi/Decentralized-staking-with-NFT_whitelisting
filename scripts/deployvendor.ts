import { ethers } from "hardhat";
const BATContract = "0x0ed64d01D0B4B655E410EF1441dD677B695639E7";
// const ICU = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";
async function DeployStake() {
  // deploting the Bored ape tokens Initial coin offering
  const BATVENDOR = await ethers.getContractFactory("vendor");
  const batvendor = await BATVENDOR.deploy(BATContract);
  await batvendor.deployed();

  const BATToken = await ethers.getContractAt("IERC20", BATContract);
  await BATToken.transfer(batvendor.address, "100000000000000000000000000");
  console.log(await BATToken.balanceOf(batvendor.address));
  console.log("batvendor_Contract", batvendor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
DeployStake().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});