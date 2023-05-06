const hre = require("hardhat");

async function main() {
  const ZKDocument = await hre.ethers.getContractFactory("ZKDocument", {
    libraries: {
      ValidDocumentId: "0xb1c5129aAd91bDcBeA38Af4C5D341cFb75FDA35A",
      ValidDocumentParticipantInsert:
        "0x12f98c19986D2014353e30Ca7aa6B76A15b35441",
    },
  });
  const zkDocument = await ZKDocument.attach(
    "0x8c0a5Dfbf3a89541236Ae529F0D143ed795a4E80"
  );

  await (
    await zkDocument.initialize(
      "0x9c66b91cff4855ddf693889335acbb0564ea19b8",
      "0xa96bb1719fa7f78b8B2d3c24BBc79e52Ae9a3988"
    )
  ).wait();
  console.log(await (await zkDocument.setupTables()).wait());

  console.log(await zkDocument.getDocumentsTableId());
  console.log(await zkDocument.getAuditLogTableId());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
