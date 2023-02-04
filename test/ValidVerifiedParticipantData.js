const { newMemEmptyTrie, buildEddsa } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidVerifiedParticipantData circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidVerifiedParticipantData.circom");
  });

  it("passes if right uniqueIdentifier is in the participant", async () => {
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
    const tree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(input).entries()) {
      await tree.insert(i, value);
    }

    const privateKey = "PRIVATE_KEY";
    const publicKey = eddsa.prv2pub(privateKey);
    const sig = eddsa.signPoseidon(privateKey, tree.root);

    const witness = await circuit.calculateWitness({
      root: tree.F.toObject(tree.root),
      key: 5,
      value: getKey("test@test.com"),
      siblings: await getSiblings(tree, 5),
      Ax: eddsa.F.toObject(publicKey[0]),
      Ay: eddsa.F.toObject(publicKey[1]),
      S: sig.S,
      R8x: eddsa.F.toObject(sig.R8[0]),
      R8y: eddsa.F.toObject(sig.R8[1]),
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
