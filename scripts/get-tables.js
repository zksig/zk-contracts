const hre = require("hardhat");

async function main() {
  const ZKDocument = await hre.ethers.getContractFactory("ZKDocument", {
    libraries: {
      ValidDocumentId: "0x17660F2fF2D313726E876fe1EE4772d8b9F32F3b",
      ValidDocumentParticipantInsert:
        "0xb8888Ae9480A459c6b9c5668AC3ED8B3D0D33959",
    },
  });
  const zkDocument = await ZKDocument.attach(
    "0x6fA47cf77A94EB92E881D3068DE9C39e7Be15C59"
  );

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
