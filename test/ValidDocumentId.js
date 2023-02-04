const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidDocumentId circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentId.circom");
  });

  it("passes if valid id", async () => {
    const input = {
      title: getKey("My Document"),
      type: getKey("RECORD"),
      structuredData: getKey(JSON.stringify({})),
      pdfCID: getKey("bx13ntoehu3434"),
      encryptedPDFCID: getKey("bxntoehui3432432"),
      pdfHash: "1234325435",
      totalPages: "10",
      encryptionKey: "1234567890",
    };

    const tree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(input).entries()) {
      await tree.insert(i, value);
    }

    const witness = await circuit.calculateWitness({
      id: tree.F.toObject(tree.root),
      ...input,
      ...Object.fromEntries(
        await Promise.all(
          Object.keys(input).map(async (key, i) => {
            return [`${key}Siblings`, await getSiblings(tree, i)];
          })
        )
      ),
    });

    // TODO fix circom_tester library so we can check output
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
