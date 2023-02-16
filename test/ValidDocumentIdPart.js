const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidDocumentIdPart circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentIdPart.circom");
  });

  it("passes if right title is in document id", async () => {
    const tree = await newMemEmptyTrie();
    await tree.insert(
      getKey("title"),
      `0x${Buffer.from("hello").toString("hex")}`
    );
    await tree.insert(getKey("totalSigners"), "1");
    await tree.insert(getKey("pdfCID"), "12345");
    await tree.insert(getKey("pdfHash"), "98765");
    await tree.insert(getKey("totalPages"), "5");
    await tree.insert(getKey("encryptionKey"), "55555");

    const a = await tree.find(1)
    a

    const witness = await circuit.calculateWitness({
      root: tree.F.toObject(tree.root),
      key: getKey("title"),
      value: `0x${Buffer.from("hello").toString("hex")}`,
      siblings: await getSiblings(tree, "title"),
    });

    // TODO fix circom_tester library so we can check output
    await circuit.checkConstraints(witness);
  });
});

function getKey(key) {
  return `0x${Buffer.from(key).toString("hex")}`;
}

async function getSiblings(tree, key) {
  const siblings = (await tree.find(getKey(key))).siblings.map((s) =>
    tree.F.toObject(s)
  );
  while (siblings.length < 5) siblings.push(0);

  return siblings;
}
