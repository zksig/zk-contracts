const { wasm } = require("circom_tester");
const { buildEddsa, newMemEmptyTrie } = require("circomlibjs");

describe("ValidDocumentParticipantInsert circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentParticipantInsert.circom");
  });

  it("passes if valid signature insert", async () => {
    const eddsa = await buildEddsa();

    const input = {
      documentId: "1234",
      initiator: 1,
      role: getKey("ORIGINATOR"),
      subrole: 0,
      name: getKey("Test Test"),
      uniqueIdentifier: getKey("test@test.com"),
      verificationIPAddress: getKey("55.55.55.55"),
      verificationMethod: getKey("email"),
      verificationTimestamp: "1234567890",
    };
    const participantTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(input).entries()) {
      await participantTree.insert(i, value);
    }

    const privateKey = "PRIVATE_KEY";
    const publicKey = eddsa.prv2pub(privateKey);
    const sig = eddsa.signPoseidon(privateKey, participantTree.root);

    const tree = await newMemEmptyTrie();
    const { oldRoot, siblings, newRoot, oldKey, isOld0 } = await tree.insert(
      sig.S,
      0
    );
    const siblingHashes = siblings.map((s) => tree.F.toObject(s));
    while (siblingHashes.length < 5) siblingHashes.push(0);
    
    const witness = await circuit.calculateWitness({
      root: participantTree.F.toObject(participantTree.root),
      ...input,
      ...Object.fromEntries(
        await Promise.all(
          Object.keys(input).map(async (key, i) => {
            return [`${key}Siblings`, await getSiblings(participantTree, i)];
          })
        )
      ),
      Ax: eddsa.F.toObject(publicKey[0]),
      Ay: eddsa.F.toObject(publicKey[1]),
      S: sig.S,
      R8x: eddsa.F.toObject(sig.R8[0]),
      R8y: eddsa.F.toObject(sig.R8[1]),
      oldRoot: tree.F.toObject(oldRoot),
      oldKey: tree.F.toObject(oldKey),
      newRoot: tree.F.toObject(newRoot),
      isOld0: isOld0 ? 1 : 0,
      siblings: siblingHashes,
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
