import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { LocalTableland } from "@tableland/local";
import { ZKDocument } from "../typechain-types";

const lt = new LocalTableland({ silent: true });

describe("ZKDocument", () => {
  let owner: SignerWithAddress;
  let contract: ZKDocument;

  before(async () => {
    lt.start();
    await lt.isReady();

    [owner] = await ethers.getSigners();
    const validDocumentIdFactory = await ethers.getContractFactory(
      "ValidDocumentId"
    );
    const validDocumentId = await validDocumentIdFactory.deploy();
    await validDocumentId.deployed();

    const validDocumentParticipantInsertFactory =
      await ethers.getContractFactory("ValidDocumentParticipantInsert");
    const validDocumentParticipantInsert =
      await validDocumentParticipantInsertFactory.deploy();
    await validDocumentParticipantInsert.deployed();

    const zkDocumentFactory = await ethers.getContractFactory("ZKDocument", {
      libraries: {
        ValidDocumentId: validDocumentId.address,
        ValidDocumentParticipantInsert: validDocumentParticipantInsert.address,
      },
    });
    contract = await zkDocumentFactory.deploy(ethers.constants.AddressZero);
    await contract.initialize(ethers.constants.AddressZero, owner.address);
    await contract.setupTables();
  });

  after(async () => {
    await lt.shutdown();
  });

  it("creates a document with valid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "15978125441550700312164022882867441640724111640108789291320310102438724058360",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "0x2de5659e40aa617dacf12b33fdf3b37011f0b3e1a62ce627c051d17656e2c9ff",
            "0x0c0a46e17119d946036fdbd445f142c4f0612ebb0252ba244d2c26cfd4bbadc2",
          ],
          b: [
            [
              "0x0fe32424024a6a1d8c38986d8a2a6f0f2fade7f88b09ba435c98a0d3e6b4f54f",
              "0x10255ed388938b1d08685e8a9fcf1294ccc27fb9f431bafa0af3caa5a057ffed",
            ],
            [
              "0x1cb6326138aa5b734431f7ba576752b898d0ae1fb250ab64e204f2d6e8369f07",
              "0x11f024a96c0c0a83e9f66271e9294ba3b58fcb75e49dec1775bcd0186adc508d",
            ],
          ],
          c: [
            "0x2dd922f9ac503798e6b2368399163a8cb61c19c1ae1249242a3c26ca50b74523",
            "0x192570be2823a29e6a1f7a93de868cfdcf8ddb09ccffb3550e1cb166ae1941ba",
          ],
        },
      })
    ).to.emit(contract, "CreateDocument");
  });

  it("fails to create a document if it already exists", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "15978125441550700312164022882867441640724111640108789291320310102438724058360",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "0x1b424f8d563950337fb376916f8ed9c29a27f019f57d0b6d59d2dcaf5ff9c9f5",
            "0x100edbf3296552abb9705ac5680de1dfd14cf8699ef4a111499a372842cb8898",
          ],
          b: [
            [
              "0x03e29a562f24ea7cb235957b768918f3afc0c19f4d28b39613306d2b799e9e1e",
              "0x217262297601801b2be04034e4ce2eb93e7993c9132e0be6fbc2577d72fedec4",
            ],
            [
              "0x00e11af8cddf7588b75dcdf34b26632c93814dec6a9006753aa4449c531d57f2",
              "0x1d75855056ed3298724d7fc0f932b5743fd7274c1b9ace2c8c37c5b3e75905b5",
            ],
          ],
          c: [
            "0x1a89af6d7c313a7e7a0aadc8817a2ce2180fddc3f5cea2ba2003fa451e2427e0",
            "0x0fb3e1b9c5111784d6445cb564e53d4277d150446d43a6149defa7f704df2e08",
          ],
        },
      })
    ).to.rejectedWith("Document exists");
  });

  it("fails to create a document with invalid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "25978125441550700312164022882867441640724111640108789291320310102438724058360",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "0x2de5659e40aa617dacf12b33fdf3b37011f0b3e1a62ce627c051d17656e2c9ff",
            "0x0c0a46e17119d946036fdbd445f142c4f0612ebb0252ba244d2c26cfd4bbadc2",
          ],
          b: [
            [
              "0x0fe32424024a6a1d8c38986d8a2a6f0f2fade7f88b09ba435c98a0d3e6b4f54f",
              "0x10255ed388938b1d08685e8a9fcf1294ccc27fb9f431bafa0af3caa5a057ffed",
            ],
            [
              "0x1cb6326138aa5b734431f7ba576752b898d0ae1fb250ab64e204f2d6e8369f07",
              "0x11f024a96c0c0a83e9f66271e9294ba3b58fcb75e49dec1775bcd0186adc508d",
            ],
          ],
          c: [
            "0x2dd922f9ac503798e6b2368399163a8cb61c19c1ae1249242a3c26ca50b74523",
            "0x192570be2823a29e6a1f7a93de868cfdcf8ddb09ccffb3550e1cb166ae1941ba",
          ],
        },
      })
    ).to.rejectedWith("verifier-gte-snark-scalar-field");
  });

  it("verifies a document with valid verified participant", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId:
          "15978125441550700312164022882867441640724111640108789291320310102438724058360",
        verifiedParticipant:
          "2238441208122065331239591035976201736478563311718947195421259944076788384240",
        encryptedParticipantCID: "5678",
        nonce: "0",
        root: "20020478736176704528763471674210344244189298963256884275413681314235999212975",
        proof: {
          a: [
            "0x1b424f8d563950337fb376916f8ed9c29a27f019f57d0b6d59d2dcaf5ff9c9f5",
            "0x100edbf3296552abb9705ac5680de1dfd14cf8699ef4a111499a372842cb8898",
          ],
          b: [
            [
              "0x03e29a562f24ea7cb235957b768918f3afc0c19f4d28b39613306d2b799e9e1e",
              "0x217262297601801b2be04034e4ce2eb93e7993c9132e0be6fbc2577d72fedec4",
            ],
            [
              "0x00e11af8cddf7588b75dcdf34b26632c93814dec6a9006753aa4449c531d57f2",
              "0x1d75855056ed3298724d7fc0f932b5743fd7274c1b9ace2c8c37c5b3e75905b5",
            ],
          ],
          c: [
            "0x1a89af6d7c313a7e7a0aadc8817a2ce2180fddc3f5cea2ba2003fa451e2427e0",
            "0x0fb3e1b9c5111784d6445cb564e53d4277d150446d43a6149defa7f704df2e08",
          ],
        },
      })
    ).to.emit(contract, "NewDocumentParticipant");
  });

  it("fails to verify an document with invalid verified participant insert", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId:
          "15978125441550700312164022882867441640724111640108789291320310102438724058360",
        verifiedParticipant:
          "2238441208122065331239591035976201736478563311718947195421259944076788384240",
        encryptedParticipantCID: "5678",
        nonce: "0",
        root: "14871602250097672757846881588375769813559635928276823201219205700637906177588",
        proof: {
          a: [
            "0x1ec0222fc87ebcb435b39af098c175d35dad9ce60e01be12447bba23794da532",
            "0x034be7d0bc7b938f7cf89d0aee503e6a2dda384adaaefcfb1ee938de2948a502",
          ],
          b: [
            [
              "0x1eb7c29cf801f810f1c34a2941d53bd10a216304e17307c04c91a5b94ee8ae7c",
              "0x240d576a282ac69a85f6a23f2d2b167eaa80a10cad105f515a15b9d8b1d67e82",
            ],
            [
              "0x19e1a5226d617d5b10c69ce8423f99d5c5255554c95dfec86c31a6c40308e066",
              "0x2e584a7bb88b8d16e0ae7ac4444091b7d260322f872b76c9f866608d157c0e2e",
            ],
          ],
          c: [
            "0x23d7648ac25b3eef878dfeb22005279d632e304182e7663020f7c4c6eb4c014b",
            "0x04802ee8b0ccea98c8d4ef463b5d815116f5a9470e3e32591df4d7180eaefd98",
          ],
        },
      })
    ).to.rejectedWith("Invalid participant insert");
  });
});
