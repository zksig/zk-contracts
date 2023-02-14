import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ZKDocument } from "../typechain-types";

describe("ZKDocument", () => {
  let owner: SignerWithAddress;
  let contract: ZKDocument;

  before(async () => {
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
  });

  it("creates a document with valid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "2681517947090539074238088567394099335031577043496352195096235932925559489572",
        proof: {
          a: [
            "0x06171930ecd55c9200d7cea66030abd9d3b7d18306e3e2f6a84bd8ca05dedc3a",
            "0x032a8dd0867dfbfd7d017fc23d2719a6067376863b95e6bba251d98e22689dfe",
          ],
          b: [
            [
              "0x1f117f5ec120d4aec5626a0da7c8343654cd68f3cc6a8a979c070f4f07d94b69",
              "0x23ca275af848c5b94e7931d86654dc9bda586223d0918b631ac430dd6c82a2ab",
            ],
            [
              "0x270d6168d08d5b3ec746ba052d63a6db15ea6f3888021a05220c448254a9c669",
              "0x0669c6b5e20020508bd7f52ae39833e4966de97084c96d3a774874d67e4d2359",
            ],
          ],
          c: [
            "0x0f59f5886d5ebe92ce73ed8ede6f55ee99a40b9c003a69e78313ecd757f5a1a9",
            "0x266e29a0fdac26e14ed4be6d09a26b8b73a2547f3dfb173002f805c7acd7ddd0",
          ],
        },
      })
    ).to.emit(contract, "CreateDocument");
  });

  it("fails to create a document if it already exists", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "2681517947090539074238088567394099335031577043496352195096235932925559489572",
        proof: {
          a: [
            "0x06171930ecd55c9200d7cea66030abd9d3b7d18306e3e2f6a84bd8ca05dedc3a",
            "0x032a8dd0867dfbfd7d017fc23d2719a6067376863b95e6bba251d98e22689dfe",
          ],
          b: [
            [
              "0x1f117f5ec120d4aec5626a0da7c8343654cd68f3cc6a8a979c070f4f07d94b69",
              "0x23ca275af848c5b94e7931d86654dc9bda586223d0918b631ac430dd6c82a2ab",
            ],
            [
              "0x270d6168d08d5b3ec746ba052d63a6db15ea6f3888021a05220c448254a9c669",
              "0x0669c6b5e20020508bd7f52ae39833e4966de97084c96d3a774874d67e4d2359",
            ],
          ],
          c: [
            "0x0f59f5886d5ebe92ce73ed8ede6f55ee99a40b9c003a69e78313ecd757f5a1a9",
            "0x266e29a0fdac26e14ed4be6d09a26b8b73a2547f3dfb173002f805c7acd7ddd0",
          ],
        },
      })
    ).to.rejectedWith("Document exists");
  });

  it("fails to create a document with invalid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "23296823064297203651311056672206079584922270552303383073992426914088382500006",
        proof: {
          a: [
            "0x286fc2fe1f607bd74a01727837d43bc5718d846d43afdc332a0bb9a37d6287ae",
            "0x24ba305e5e1c8f04f3a4c8dd46b625b24c3e8ecb8c97f51cdacab50150984dee",
          ],
          b: [
            [
              "0x04726a41c4a57353045e214c79d2baf74b982452d14c9580ea05c4890c864a78",
              "0x0fc9d4109c20b8cf65f6c9fbdba343a1ab3c06d5a0f71faafe7b52dfaef951b3",
            ],
            [
              "0x1c8f4edeade225be33907d170fc54178d3830e4938e36a7d27bbff2c3e2d7e85",
              "0x2779541671a8dbb9d9af03d71032280918237320ff2960f939eb15c1a6ef53e3",
            ],
          ],
          c: [
            "0x0ffe66ffefa8d56ea4647b9e0cacb9a850523fd5ff2fd22cebf4d58c4d8e47b1",
            "0x2963e8f222315d3724220dd080cd1d0bb705b299e5e034be4e898e85f910f5c7",
          ],
        },
      })
    ).to.rejectedWith("verifier-gte-snark-scalar-field");
  });

  it("verifies a document with valid verified participent", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId: "1234",
        verifiedParticipant: {
          R8x: "16844334354896989292851686234036420751510292515605239337527144416587540786328",
          R8y: "18160083385031099892614470727750567556244249189522956647222288739547131488475",
          S: "2240652869225213511945653276317594857594074121096333863038997623645813707759",
        },
        root: "3285937326252959461671809330765769524277251882929110868042172136442348719329",
        proof: {
          a: [
            "0x0d2586b30c4a8d790be540724c6c6da1e6e92800bf0775ed3dc696ae8d092ca4",
            "0x2dbf62c64894c8d68f62f0f9f1c304896ae9523fe792068686418c36ce6f42a4",
          ],
          b: [
            [
              "0x20554bb16c15e72bd20821a9b1cb1d609fb5fec566e1756c6db1e1e88f61cd7a",
              "0x12a2228d5b1bc6e3054485aee6f5190d3924dff35a279b48c65d31e497a8303e",
            ],
            [
              "0x21901bf4d467bd1491d91a92401f68d0d9ee592b0138ee9d32b4dad498e725d0",
              "0x2c4f57ab22eb59eb1d16ded55e2b128d5ce99a8231012d0cd2da8469b213ec84",
            ],
          ],
          c: [
            "0x01dd8bd8e256193a97dba3ef7f3ab6c403aaaac49d5b018660fe63321bc1a94b",
            "0x1e64d155b64ee307541db1af064b97b544891a6cf6139baf47e2dbbf1928a83e",
          ],
        },
      })
    ).to.emit(contract, "NewDocumentParticipant");
  });

  it("fails to verify an document with invalid verified participant insert", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId: "1234",
        verifiedParticipant: {
          R8x: "1234",
          R8y: "4567",
          S: "90898",
        },
        root: "2285937326252959461671809330765769524277251882929110868042172136442348719329",
        proof: {
          a: [
            "0x27a35f73192202abb1b920265c2d39c75f838a57b940c28fbc59c3e5d8de5828",
            "0x14718ae8b48fffcd165a6de93a0294164397c6c2442cff1b4ea6cfa3c6a3a57d",
          ],
          b: [
            [
              "0x2a514f2c3aaed1acbf1c1f62b7ad8293a1136fbad8e66f5c8d87e098fe84838a",
              "0x2e356b95ababaa6870d795e2f873718daa07bfc0f1d821dc43b3af7ee1c85347",
            ],
            [
              "0x29cb1fbae41c2c0a70d9c34e5990520e38c2cf6521143d4060a3c79edb6956cb",
              "0x1a57744f9354d4cf21e8f18dae0e403b6eb8c11da98660eb931600f1abe19c05",
            ],
          ],
          c: [
            "0x0d0e8f273726062cf2d8f32ea8ee834ea6d82ec521035b9cb9333359a1744abc",
            "0x246258580fe57ac2fe8a3ef22438cfcb0057fb9938eaf3ed90cc646cd2aa58d9",
          ],
        },
      })
    ).to.rejectedWith("Invalid participant insert");
  });
});
