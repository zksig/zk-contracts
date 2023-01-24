const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidAgreementPage circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidAgreementPage.circom");
  });

  it("passes if page is included", async () => {
    const tree = await newMemEmptyTrie();
    await tree.insert(2, 0);
    await tree.insert(1, 0);
    await tree.insert(3, 0);
    await tree.insert(4, 0);
    const siblingHashes = (await tree.find(3)).siblings.map((s) =>
      tree.F.toObject(s)
    );
    while (siblingHashes.length < 10) siblingHashes.push(0);

    const witness = await circuit.calculateWitness({
      title: "43434",
      totalSigners: "10",
      pdfCID: "12345",
      pdfHash: tree.F.toObject(tree.root),
      totalPages: "4",
      encryptionKey: "12345",
      agreementId:
        "15672289171331961726174349807060979975311854093145864462589715964709036733829",
      siblings: siblingHashes,
      pageHash: 3,
    });

    await circuit.checkConstraints(witness);
  });
});
