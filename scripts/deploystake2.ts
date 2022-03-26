import { Signer } from "ethers";
import { ethers, network } from "hardhat";
const BATContract = "0x0ed64d01D0B4B655E410EF1441dD677B695639E7";
const batvendor_Contract = "0x4bf010f1b9beDA5450a8dD702ED602A104ff65EE";
const BoreApeNFT= "0xBC4CA0EDA7647A8Ab7C2061C2E118A18A936F13D";
const NFTHolder = "0x720a4fab08cb746fc90e88d1924a98104c0822cf";

async function StakingContract() {
  // deploying the staking contract
  const staking = await ethers.getContractFactory("StakingRewards");
  const stakingContract = await staking.deploy(
    BoreApeNFT,
    BATContract
  );
  await stakingContract.deployed();
  console.log("staking contract address", stakingContract.address);

  // introducing a staker
  // getting the tokenvendor contract
  const batvendor2 = await ethers.getContractAt("vendor", batvendor_Contract);

  // getting the BAT contracts
  const BAT = await ethers.getContractAt("BoredApeTokens", BATContract);

  console.log("impersonating the staker");
  // @ts-ignore
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [NFTHolder], // address to impersonate
  });
  const signer1: Signer = await ethers.getSigner(NFTHolder);

  console.log("setting balance of NFTHolder");
  // ts-ignore
  await network.provider.send("hardhat_setBalance", [
    NFTHolder,
    "0x56BC75E2D63100000",
  ]);

  console.log("buying the BAT tokens for the staker");
  await batvendor2.connect(signer1).buy({ value: "50000000000000000000" });
  console.log(
    "current balance after bying",
    await BAT.connect(signer1).balanceOf(NFTHolder)
  );

  console.log("approving tokens for Staking contract");
  await BAT.connect(signer1).approve(
    stakingContract.address,
    "200000000000000000000"
  );

  console.log("Staking tokens");
  await stakingContract.connect(signer1).stake("200000000000000000000");

  
  console.log("balance after staking token", await BAT.connect(signer1).balanceOf(NFTHolder));

  // withdraw tokens
  await stakingContract.connect(signer1).withdraw("10000000000000000000");
  // check token balance
  console.log(
    "balance after getting half staked token back",
    await BAT.connect(signer1).balanceOf(NFTHolder)
  );

  // updating stake amount
  await BAT.connect(signer1).approve(
    stakingContract.address,
    "200000000000000000000"
  );
  await stakingContract.connect(signer1).stake("200000000000000000000");
  console.log(
    "balance after staking another 200 tokens",
    await BAT.connect(signer1).balanceOf(NFTHolder)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
StakingContract().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});