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
    const participantTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(input).entries()) {
      await participantTree.insert(i, value);
    }

    const privateKey = "PRIVATE_KEY";
    const publicKey = eddsa.prv2pub(privateKey);
    const sig = eddsa.signPoseidon(privateKey, participantTree.root);

    const documentParticipantsTree = await newMemEmptyTrie();
    await documentParticipantsTree.insert(sig.S, 0);
    for (let i = 0; i < 30; i++) {
      await documentParticipantsTree.insert(
        `22406528692252135119456532763175948575940741210963338630389976236458137077${i
          .toString()
          .padStart(2, "0")}`,
        0
      );
    }

    const witness = await circuit.calculateWitness({
      participantsRoot: documentParticipantsTree.F.toObject(
        documentParticipantsTree.root
      ),
      participantSiblings: await getSiblings(
        documentParticipantsTree,
        sig.S,
        20
      ),
      participantId: participantTree.F.toObject(participantTree.root),
      key: 5,
      value: getKey("test@test.com"),
      siblings: await getSiblings(participantTree, 5),
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

async function getSiblings(tree, key, total = 5) {
  const siblings = (await tree.find(key)).siblings.map((s) =>
    tree.F.toObject(s)
  );
  while (siblings.length < total) siblings.push(0);

  return siblings;
}
