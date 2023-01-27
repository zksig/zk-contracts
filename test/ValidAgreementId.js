const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidAgreementId circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidAgreementId.circom");
  });

  it("passes if valid id", async () => {
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

    const witness = await circuit.calculateWitness({
      root: tree.F.toObject(tree.root),
      title: `0x${Buffer.from("hello").toString("hex")}`,
      titleSiblings: await getSiblings(tree, "title"),
      totalSigners: "1",
      totalSignersSiblings: await getSiblings(tree, "totalSigners"),
      pdfCID: "12345",
      pdfCIDSiblings: await getSiblings(tree, "pdfCID"),
      pdfHash: "98765",
      pdfHashSiblings: await getSiblings(tree, "pdfHash"),
      totalPages: "5",
      totalPagesSiblings: await getSiblings(tree, "totalPages"),
      encryptionKey: "55555",
      encryptionKeySiblings: await getSiblings(tree, "encryptionKey"),
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
  while (siblings.length < 10) siblings.push(0);

  return siblings;
}
