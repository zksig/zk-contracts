const { newMemEmptyTrie } = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ValidParticipant circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidParticipant.circom");
  });

  it("passes if valid participant", async () => {
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

    const witness = await circuit.calculateWitness({
      root: tree.F.toObject(tree.root),
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
