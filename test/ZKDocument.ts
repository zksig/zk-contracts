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
          "13296823064297203651311056672206079584922270552303383073992426914088382500006",
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
    ).to.emit(contract, "CreateDocument");
  });

  it("fails to create a document if it already exists", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "13296823064297203651311056672206079584922270552303383073992426914088382500006",
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
          R8x: "1234",
          R8y: "4567",
          S: "90898",
        },
        root: "3285937326252959461671809330765769524277251882929110868042172136442348719329",
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
