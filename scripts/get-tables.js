const hre = require("hardhat");

async function main() {
  const ZKDocument = await hre.ethers.getContractFactory("ZKDocument", {
    libraries: {
      ValidDocumentId: "0xc76B836b2489E65BF7F7593E725D333b086E6341",
      ValidDocumentParticipantInsert:
        "0xa295b447f30b3c947CAD05eB09aBDf7D3AdA905F",
    },
  });
  const zkDocument = await ZKDocument.attach(
    "0xDFE8Be6e3F5a08696106eD2133EE57Ee8164082e"
  );

  // console.log(await (await zkDocument.setupTables()).wait());

  console.log(await zkDocument.getDocumentsTableId());
  console.log(await zkDocument.getAuditLogTableId());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
