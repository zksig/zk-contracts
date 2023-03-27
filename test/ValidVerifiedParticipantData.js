const {
  ZKParticipantLogs,
  ZKDocumentParticipant,
  ParticipantRole,
  PoseidonHasher,
  PrivateKeyIdentity,
  ZKStructuredData,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidVerifiedParticipantData circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidVerifiedParticipantData.circom");
  });

  it("passes if right uniqueIdentifier is in the participant", async () => {
    const zkParticipant = new ZKDocumentParticipant({
      documentId: BigInt(12345),
      initiator: true,
      role: ParticipantRole.ORIGINATOR,
      subrole: "manager",
      name: "Test Test",
      uniqueIdentifier: "test@test.com",
      structuredData: new ZKStructuredData({ structuredData: [] }),
      signature: Buffer.from("test test"),
      verificationData: {},
      hasher: new PoseidonHasher(),
    });

    const details = await zkParticipant.getDetails();

    const logs = new ZKParticipantLogs([]);
    const identity = new PrivateKeyIdentity({
      privateKey: "PRIVATE_KEY",
      uniqueIdentifier: "test@test.com",
      verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
    });
    const input = await logs.insert({ zkParticipant, identity });

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
