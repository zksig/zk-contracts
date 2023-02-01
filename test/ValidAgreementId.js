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
      `0x${Buffer.from("o").toString("hex")}`
    );
    await tree.insert(getKey("totalSigners"), "2");
    await tree.insert(getKey("pdfCID"), "");
    await tree.insert(getKey("pdfHash"), "");
    await tree.insert(getKey("totalPages"), "10");
    await tree.insert(
      getKey("encryptionKey"),
      "0x50f160e83b4bbee7f35b3e589233d4b30e6832c635cb395473bde5887a82052f"
    );

    const witness = await circuit.calculateWitness({
      root: tree.F.toObject(tree.root),
      title: `0x${Buffer.from("o").toString("hex")}`,
      titleSiblings: await getSiblings(tree, "title"),
      totalSigners: "2",
      totalSignersSiblings: await getSiblings(tree, "totalSigners"),
      pdfCID: "",
      pdfCIDSiblings: await getSiblings(tree, "pdfCID"),
      pdfHash: "",
      pdfHashSiblings: await getSiblings(tree, "pdfHash"),
      totalPages: "10",
      totalPagesSiblings: await getSiblings(tree, "totalPages"),
      encryptionKey:
        "0x50f160e83b4bbee7f35b3e589233d4b30e6832c635cb395473bde5887a82052f",
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
