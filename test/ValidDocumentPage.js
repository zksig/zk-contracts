const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidDocumentPage circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentPage.circom");
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
    while (siblingHashes.length < 20) siblingHashes.push(0);

    const agreementTree = await newMemEmptyTrie();
    await agreementTree.insert(5, agreementTree.F.toObject(tree.root));
    const pdfHashSiblings = (await agreementTree.find(5)).siblings.map((s) =>
      agreementTree.F.toObject(s)
    );
    while (pdfHashSiblings.length < 5) pdfHashSiblings.push(0);

    const witness = await circuit.calculateWitness({
      pdfHashSiblings,
      pdfHash: tree.F.toObject(tree.root),
      documentId: agreementTree.F.toObject(agreementTree.root),
      siblings: siblingHashes,
      pageHash: 3,
    });

    await circuit.checkConstraints(witness);
  });
});
