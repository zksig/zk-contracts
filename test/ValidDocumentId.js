const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidDocumentId circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentId.circom");
  });

  it("passes if valid id", async () => {
    const input = {
      title: "0x6f6561756f65",
      
      type: 0,
     
      structuredData:
        "6072778328777765686589340087799057556784077494424838987042795657960714018233",
      
      pdfCID:
        "92938440291377228167023122387715733773952570569913272894969855708369091397367",

      encryptedPDFCID:
        "66132394148006428570698526826293624003915457023859713020013652222321953396390",
 
      pdfHash:
        "10157129442320636078015441239429970930350473330240347321202968045414332801408",

      totalPages: "6",

      encryptionKey:
        "0xd0c8ba79582d79bd268c5d01bb7ba01794fe8d6c8841a11019141d4cada5402e",

    };

    // const input = {
    //   title: getKey("My Document"),
    //   type: getKey("RECORD"),
    //   structuredData: getKey(JSON.stringify({})),
    //   pdfCID: getKey("bx13ntoehu3434"),
    //   encryptedPDFCID: getKey("bxntoehui3432432"),
    //   pdfHash: "1234325435",
    //   totalPages: "10",
    //   encryptionKey: "1234567890",
    // };

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
