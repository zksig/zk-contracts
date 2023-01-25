import { ethers } from "hardhat";

async function main() {
  const ValidAgreementId = await ethers.getContractFactory("ValidAgreementId");
  const validAgreementId = await ValidAgreementId.deploy();
  await validAgreementId.deployed();

  const ZKAgreement = await ethers.getContractFactory("ZKAgreement", {
    libraries: {
      ValidAgreementId: validAgreementId.address,
    },
  });
  const zkAgreement = await ZKAgreement.deploy();
  await zkAgreement.deployed();

  console.log(`Deployed to ${zkAgreement.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
