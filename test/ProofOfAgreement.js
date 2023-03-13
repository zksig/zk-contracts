const {
  newMemEmptyTrie,
  buildEddsa,
  buildPedersenHash,
} = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ProofOfAgreement circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ProofOfAgreement.circom");
  });

  it("passes if valid proof of signature is passed", async () => {
    const eddsa = await buildEddsa();
    const pedersen = await buildPedersenHash();

    const document = {
      title: getKey(pedersen.hash("Employment Agreement")),
      type: 0,
      structuredData:
        "6072778328777765686589340087799057556784077494424838987042795657960714018233",
      pdfCID:
        "92588233037783879563969273043159908070107399956055470360226357353108525156563",
      encryptedPDFCID:
        "92588233021354542797278455929580698293874520116291359088333709197636803149257",
      pdfHash:
        "10157129442320636078015441239429970930350473330240347321202968045414332801408",
      totalPages: "6",
      encryptionKey:
        "0xd0c8ba79582d79bd268c5d01bb7ba01794fe8d6c8841a11019141d4cada5402e",
    };

    const documentTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(document).entries()) {
      await documentTree.insert(i, value);
    }

    const witness = await circuit.calculateWitness({
      documentId: documentTree.F.toObject(documentTree.root),
      documentTitle: getKey(pedersen.hash("Employment Agreement")),
      pdfHash:
        "10157129442320636078015441239429970930350473330240347321202968045414332801408",
      structuredData:
        "6072778328777765686589340087799057556784077494424838987042795657960714018233",
      documentTitleSiblings: await getSiblings(documentTree, 0),
      pdfHashSiblings: await getSiblings(documentTree, 5),
      structuredDataSiblings: await getSiblings(documentTree, 2),
    });

    await circuit.checkConstraints(witness);
  });
});

function getKey(key) {
  return `0x${Buffer.from(key).toString("hex")}`;
}

async function getSiblings(tree, key, total = 5) {
  const siblings = (await tree.find(key)).siblings.map((s) =>
    tree.F.toObject(s)
  );
  while (siblings.length < total) siblings.push(0);

  return siblings;
}
