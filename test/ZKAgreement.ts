import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ZKAgreement } from "../typechain-types";

describe("ZKAgreement", () => {
  let owner: SignerWithAddress;
  let contract: ZKAgreement;

  before(async () => {
    [owner] = await ethers.getSigners();
    const validAgreementIdFactory = await ethers.getContractFactory(
      "ValidAgreementId"
    );
    const validAgreementId = await validAgreementIdFactory.deploy();
    await validAgreementId.deployed();

    const validAgreementSignatureInsertFactory =
      await ethers.getContractFactory("ValidAgreementSignatureInsert");
    const validAgreementSignatureInsert =
      await validAgreementSignatureInsertFactory.deploy();
    await validAgreementSignatureInsert.deployed();

    const zkAgreementFactory = await ethers.getContractFactory("ZKAgreement", {
      libraries: {
        ValidAgreementId: validAgreementId.address,
        ValidAgreementSignatureInsert: validAgreementSignatureInsert.address,
      },
    });
    contract = await zkAgreementFactory.deploy(ethers.constants.AddressZero);
  });

  it("creates an agreement with valid id", async () => {
    return expect(
      contract.createAgreement({
        agreementId:
          "13941015527571102340410628630818016248458943493630149538961808525202573893520",
        proof: {
          a: [
            "0x2f02516c0c050e8d29fb5f06653f6c31190b1ca0f9bbc949b5f56898ec317db6",
            "0x236ce8641a65088b443daf66600686bc79c9273b6e7ecf9f094d1e5a2bbc2de6",
          ],
          b: [
            [
              "0x20c4da9d589bfab58da803f54a636701c26d5cf20ec8df931c085765250040d4",
              "0x1de9ee083ef9bf1963431b89d87c7213c935012ec501f62910609f5bd75b3324",
            ],
            [
              "0x0ebcfe32a41c46e336c5c4739eb66f8543ffd7866e92c0c74eb88f3dda8ebeb2",
              "0x206bd0f39ea1f9a3dcd4737f412b6d90a70f181a8f1610165283aede351c3e00",
            ],
          ],
          c: [
            "0x2bc0393c0c48e1aae7190de0970b0af2d87e4d7ec10f7c693aafdf92e0dd6581",
            "0x2cc5fb13d27058de4dd1c5137ec0aedd5c45e9c53c4b47d6ce0c66b12488c524",
          ],
        },
      })
    ).to.emit(contract, "CreateAgreement");
  });

  it("fails to create an agreement if it already exists", async () => {
    return expect(
      contract.createAgreement({
        agreementId:
          "13941015527571102340410628630818016248458943493630149538961808525202573893520",
        proof: {
          a: [
            "0x2f02516c0c050e8d29fb5f06653f6c31190b1ca0f9bbc949b5f56898ec317db6",
            "0x236ce8641a65088b443daf66600686bc79c9273b6e7ecf9f094d1e5a2bbc2de6",
          ],
          b: [
            [
              "0x20c4da9d589bfab58da803f54a636701c26d5cf20ec8df931c085765250040d4",
              "0x1de9ee083ef9bf1963431b89d87c7213c935012ec501f62910609f5bd75b3324",
            ],
            [
              "0x0ebcfe32a41c46e336c5c4739eb66f8543ffd7866e92c0c74eb88f3dda8ebeb2",
              "0x206bd0f39ea1f9a3dcd4737f412b6d90a70f181a8f1610165283aede351c3e00",
            ],
          ],
          c: [
            "0x2bc0393c0c48e1aae7190de0970b0af2d87e4d7ec10f7c693aafdf92e0dd6581",
            "0x2cc5fb13d27058de4dd1c5137ec0aedd5c45e9c53c4b47d6ce0c66b12488c524",
          ],
        },
      })
    ).to.rejectedWith("Agreement exists");
  });

  it("fails to create an agreement with invalid id", async () => {
    return expect(
      contract.createAgreement({
        agreementId:
          "25672289171331961726174349807060979975311854093145864462589715964709036733828",
        proof: {
          a: [
            "0x2f02516c0c050e8d29fb5f06653f6c31190b1ca0f9bbc949b5f56898ec317db6",
            "0x236ce8641a65088b443daf66600686bc79c9273b6e7ecf9f094d1e5a2bbc2de6",
          ],
          b: [
            [
              "0x20c4da9d589bfab58da803f54a636701c26d5cf20ec8df931c085765250040d4",
              "0x1de9ee083ef9bf1963431b89d87c7213c935012ec501f62910609f5bd75b3324",
            ],
            [
              "0x0ebcfe32a41c46e336c5c4739eb66f8543ffd7866e92c0c74eb88f3dda8ebeb2",
              "0x206bd0f39ea1f9a3dcd4737f412b6d90a70f181a8f1610165283aede351c3e00",
            ],
          ],
          c: [
            "0x2bc0393c0c48e1aae7190de0970b0af2d87e4d7ec10f7c693aafdf92e0dd6581",
            "0x2cc5fb13d27058de4dd1c5137ec0aedd5c45e9c53c4b47d6ce0c66b12488c524",
          ],
        },
      })
    ).to.rejectedWith("verifier-gte-snark-scalar-field");
  });

  it("signs an agreement with valid signature", async () => {
    return expect(
      contract.signAgreement({
        agreementId:
          "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        root: "11138567854912611493926693428430420645437166165045302007425203386365416754882",
        proof: {
          a: [
            "0x0ca337a986a78cd760e0188a8ba2d4fac631faf78b9307c1cd434d2f72692d9c",
            "0x0e36b4a4bca1b9ccd170a110612204982cd61b0f658229f27ee558d7ee6bdd68",
          ],
          b: [
            [
              "0x1295771f6140b49109b16e940c86dda24d6a2c019274be7805be971fc18e113c",
              "0x14529d95c96a3ce83bc548eae3daf156448ea9604676986705915c692da6aa7c",
            ],
            [
              "0x22c7275e1d08ca5afaa2d35404c2d62867e5c9eccd7e84692f33a48a2e2edb77",
              "0x0882639f7647e58cce109fea7714222353494e9525e71aaf4b4aadcd340db020",
            ],
          ],
          c: [
            "0x12b800cce9419b9d90b6de1b06923c77e5e85cfd807bab438c5c34bbcf925edb",
            "0x2500cfeb75ab417e181b43fa3029e2b5df546d2342edb87c2ec4f7797e008b7a",
          ],
        },
      })
    ).to.emit(contract, "SignAgreement");
  });

  it("fails to sign an agreement with invalid signature insert", async () => {
    return expect(
      contract.signAgreement({
        agreementId:
          "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        root: "21138567854912611493926693428430420645437166165045302007425203386365416754882",
        proof: {
          a: [
            "0x0ca337a986a78cd760e0188a8ba2d4fac631faf78b9307c1cd434d2f72692d9c",
            "0x0e36b4a4bca1b9ccd170a110612204982cd61b0f658229f27ee558d7ee6bdd68",
          ],
          b: [
            [
              "0x1295771f6140b49109b16e940c86dda24d6a2c019274be7805be971fc18e113c",
              "0x14529d95c96a3ce83bc548eae3daf156448ea9604676986705915c692da6aa7c",
            ],
            [
              "0x22c7275e1d08ca5afaa2d35404c2d62867e5c9eccd7e84692f33a48a2e2edb77",
              "0x0882639f7647e58cce109fea7714222353494e9525e71aaf4b4aadcd340db020",
            ],
          ],
          c: [
            "0x12b800cce9419b9d90b6de1b06923c77e5e85cfd807bab438c5c34bbcf925edb",
            "0x2500cfeb75ab417e181b43fa3029e2b5df546d2342edb87c2ec4f7797e008b7a",
          ],
        },
      })
    ).to.rejectedWith("Invalid signature insert");
  });
});
