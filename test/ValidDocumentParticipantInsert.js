const {
  ZKParticipantLogs,
  ZKDocumentParticipant,
  ParticipantRole,
  PrivateKeyIdentity,
  PoseidonHasher,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidDocumentParticipantInsert circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentParticipantInsert.circom");
  });

  it("passes if valid signature insert", async () => {
    const participant = new ZKDocumentParticipant({
      documentId: BigInt(12345),
      initiator: true,
      role: ParticipantRole.ORIGINATOR,
      subrole: "manager",
      signature: Buffer.from("ryan"),
      identity: new PrivateKeyIdentity({
        privateKey: "PRIVATE_KEY",
        uniqueIdentifier: "ryan",
        verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
      }),
      hasher: new PoseidonHasher(),
    });

    const logs = new ZKParticipantLogs([]);
    const input = await logs.insert(participant);

    const witness = await circuit.calculateWitness(input);

    await circuit.checkConstraints(witness);
  });
});
