const {
  ZKParticipantLogs,
  ZKDocumentParticipant,
  ParticipantRole,
  PrivateKeyIdentity,
  PoseidonHasher,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidVerifiedParticipantData circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidVerifiedParticipantData.circom");
  });

  it("passes if right uniqueIdentifier is in the participant", async () => {
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

    const details = await participant.getDetails();

    const logs = new ZKParticipantLogs([]);
    const input = await logs.insert(participant);

    const witness = await circuit.calculateWitness({
      participantsRoot: input.newRoot,
      participantSiblings: input.siblings,
      participantId: input.participantId,

      key: details.role.key,
      value: details.role.hashed,
      siblings: input.roleSiblings,

      Ax: input.Ax,
      Ay: input.Ay,
      S: input.S,
      R8x: input.R8x,
      R8y: input.R8y,
    });

    await circuit.checkConstraints(witness);
  });
});
