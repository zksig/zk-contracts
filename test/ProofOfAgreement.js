const { readFile } = require("fs/promises");
const { getProofOfAgreementInputs, DocumentType } = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ProofOfAgreement circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ProofOfAgreement.circom");
  });

  it("passes if valid proof of signature is passed", async () => {
    const input = await getProofOfAgreementInputs({
      title: "My Title",
      initiatorUniqueIdentifier: "test@test.com",
      type: DocumentType.AGREEMENT,
      pdf: await readFile("./fw9.pdf"),
      structuredData: [],
      encryptionKey: Buffer.from("a".repeat(32)),
    });

    const witness = await circuit.calculateWitness(input);
    await circuit.checkConstraints(witness);
  });
});
