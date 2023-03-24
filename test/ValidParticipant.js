const {
  ZKDocumentParticipant,
  PrivateKeyIdentity,
  PoseidonHasher,
  ParticipantRole,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidParticipant circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidParticipant.circom");
  });

  it("passes if valid participant", async () => {
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
    const witness = await circuit.calculateWitness(input);

    // TODO fix circom_tester library so we can check output
    await circuit.checkConstraints(witness);
  });
});
