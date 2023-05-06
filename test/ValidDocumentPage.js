const {
  ZKDocument,
  DocumentType,
  ZKDocumentPDF,
  ZKStructuredData,
  StructuredDataType,
  KeccakHasher,
} = require("@zksig/sdk");
const { readFile } = require("fs/promises");
const { wasm } = require("circom_tester");

describe("ValidDocumentPage circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentPage.circom");
  });

  it("passes if page is included", async () => {
    const zkDocument = new ZKDocument({
      title: "My Title",
      initiatorUniqueIdentifier: "test@test.com",
      type: DocumentType.AGREEMENT,
      pdf: new ZKDocumentPDF({
        pdf: await readFile("./fw9.pdf"),
        hasher: new KeccakHasher(),
      }),
      structuredData: new ZKStructuredData({
        structuredData: [
          { name: "Field-1", type: StructuredDataType.TEXT, value: "hi" },
        ],
        hasher: new KeccakHasher(),
      }),
      encryptionKey: Buffer.from("a".repeat(32)),
      hasher: new KeccakHasher(),
      validDocumentIdWASM: "",
      validDocumentIdZKey: "",
    });

    const input = await zkDocument.getProofOfPageInput(1);

    const witness = await circuit.calculateWitness(input);

    await circuit.checkConstraints(witness);
  });
});
