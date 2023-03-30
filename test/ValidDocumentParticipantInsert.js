const {
  ZKParticipantLogs,
  ZKDocumentParticipant,
  ParticipantRole,
  PoseidonHasher,
  PrivateKeyIdentity,
  ZKStructuredData,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");

describe("ValidDocumentParticipantInsert circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidDocumentParticipantInsert.circom");
  });

  it("passes if valid signature insert", async () => {
    const zkParticipant = new ZKDocumentParticipant({
      documentId: BigInt(
        "15978125441550700312164022882867441640724111640108789291320310102438724058360"
      ),
      initiator: true,
      role: ParticipantRole.ORIGINATOR,
      subrole: "manager",
      name: "Test Test",
      uniqueIdentifier: "test@test.com",
      structuredData: new ZKStructuredData({ structuredData: [] }),
      signature: Buffer.from("test"),
      verificationData: {},
      hasher: new PoseidonHasher(),
    });

    const logs = new ZKParticipantLogs([]);
    const identity = new PrivateKeyIdentity({
      privateKey: "PRIVATE_KEY",
      uniqueIdentifier: "test@test.com",
      verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
    });

    const input = await logs.insert({ zkParticipant, identity });
    const witness = await circuit.calculateWitness(input);
    await circuit.checkConstraints(witness);
  });
});
