const { newMemEmptyTrie, buildPoseidon } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidStructuredDataItem circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidStructuredDataItem.circom");
  });

  it("passes if structured data is included", async () => {
    const poseidon = await buildPoseidon();

    const item1 = poseidon([1, 100, 100, 200, 500, 2, getKey("salary"), 1]);
    const item2 = poseidon([2, 200, 250, 300, 100, 2, getKey("name"), 0]);

    const tree = await newMemEmptyTrie();
    await tree.insert(0, getKey(item1));
    await tree.insert(1, getKey(item2));
    for (let i = 2; i <= 2 ** 8; i++) {
      await tree.insert(
        i,
        getKey([i, 200, 250, 300, 100, 2, getKey("name"), 0])
      );
    }
    const siblingHashes = (await tree.find(1)).siblings.map((s) =>
      tree.F.toObject(s)
    );
    while (siblingHashes.length < 9) siblingHashes.push(0);

    const input = {
      title: getKey("My Document"),
      type: 1,
      structuredData: tree.F.toObject(tree.root),
      pdfCID: getKey("bx13ntoehu3434"),
      encryptedPDFCID: getKey("bxntoehui3432432"),
      pdfHash: "1234325435",
      totalPages: "10",
      encryptionKey: "1234567890",
    };

    const documentIdTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(input).entries()) {
      await documentIdTree.insert(i, value);
    }

    const witness = await circuit.calculateWitness({
      id: documentIdTree.F.toObject(documentIdTree.root),
      ...input,
      ...Object.fromEntries(
        await Promise.all(
          Object.keys(input).map(async (key, i) => {
            return [`${key}Siblings`, await getSiblings(documentIdTree, i)];
          })
        )
      ),

      siblings: siblingHashes,
      key: 1,
      itemHash: getKey(item2),
    });

    await circuit.checkConstraints(witness);
  });
});

function getKey(key) {
  return `0x${Buffer.from(key).toString("hex")}`;
}

async function getSiblings(tree, key) {
  const siblings = (await tree.find(key)).siblings.map((s) =>
    tree.F.toObject(s)
  );
  while (siblings.length < 5) siblings.push(0);

  return siblings;
}
