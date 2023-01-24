const { wasm } = require("circom_tester");

describe("ValidAgreementId circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidAgreementId.circom");
  });

  it("passes if valid id", async () => {
    const witness = await circuit.calculateWitness({
      title: "43434",
      totalSigners: "10",
      pdfCID: "12345",
      pdfHash: "98765",
      totalPages: "4",
      encryptionKey: "12345",
    });

    // TODO fix circom_tester library so we can check output
    await circuit.checkConstraints(witness);
  });
});
