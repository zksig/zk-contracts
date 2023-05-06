const {
  ZKDocumentParticipant,
  ParticipantRole,
  PrivateKeyIdentity,
  ZKStructuredData,
  KeccakHasher,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidVerifiedParticipant circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidVerifiedParticipant.circom");
  });

  it("passes if valid signature", async () => {
    const participant = new ZKDocumentParticipant({
      documentId: BigInt(12345),
      initiator: true,
      role: ParticipantRole.ORIGINATOR,
      subrole: "manager",
      name: "Test Test",
      uniqueIdentifier: "test@test.com",
      structuredData: new ZKStructuredData({ structuredData: [] }),
      signature: Buffer.from("test"),
      verificationData: {},
      signatureTimestamp: 12345,
      hasher: new KeccakHasher(),
    });

    const input = await participant.getProofInput();
    const identity = new PrivateKeyIdentity({
      privateKey: "PRIVATE_KEY",
      uniqueIdentifier: "test@test.com",
      verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
    });
    const { Ax, Ay } = await identity.getPublicKey();
    const { R8x, R8y, S } = await identity.sign(input.participantId);

    const witness = await circuit.calculateWitness({
      ...input,
      Ax,
      Ay,
      S,
      R8x,
      R8y,
    });

    await circuit.checkConstraints(witness);
  });
});
