const {
  ZKDocumentParticipant,
  ParticipantRole,
  PrivateKeyIdentity,
  PoseidonHasher,
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
      signature: Buffer.from("ryan"),
      identity: new PrivateKeyIdentity({
        privateKey: "PRIVATE_KEY",
        uniqueIdentifier: "ryan",
        verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
      }),
      hasher: new PoseidonHasher(),
    });

    const input = await participant.getProofInputs();

    const { Ax, Ay } = await participant.identity.getPublicKey();
    const { R8x, R8y, S } = await participant.getSignature();

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
