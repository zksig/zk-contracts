const { readFile } = require("fs/promises");
const {
  getProofOfSignatureInputs,
  DocumentType,
  ParticipantRole,
  ZKDocument,
  ZKDocumentPDF,
  ZKStructuredData,
  ZKDocumentParticipant,
  PrivateKeyIdentity,
  KeccakHasher,
} = require("@zksig/sdk");
const { wasm } = require("circom_tester");
const { Eddsa } = require("@iden3/js-crypto");

describe("ProofOfSignature circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ProofOfSignature.circom");
  });

  it("passes if valid proof of signature is passed", async () => {
    const zkDocument = new ZKDocument({
      title: "My Title",
      initiatorUniqueIdentifier: "test@test.com",
      type: DocumentType.AGREEMENT,
      pdf: new ZKDocumentPDF({
        pdf: await readFile("./fw9.pdf"),
        hasher: new KeccakHasher(),
      }),
      structuredData: new ZKStructuredData({
        structuredData: [],
        hasher: new KeccakHasher(),
      }),
      encryptionKey: Buffer.from("a".repeat(32)),
      hasher: new KeccakHasher(),
      validDocumentIdWASM: "",
      validDocumentIdZKey: "",
    });

    const documentId = (await zkDocument.getRoot()).bigInt();

    const signerIdentity = new PrivateKeyIdentity({
      privateKey: "SIGNER_PRIVATE_KEY",
      uniqueIdentifier: "signer@test.com",
      verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
    });
    const signer = new ZKDocumentParticipant({
      documentId,
      initiator: false,
      role: ParticipantRole.SIGNER,
      subrole: "",
      name: "Test Signer",
      uniqueIdentifier: await signerIdentity.getUniqueIdentifier(),
      structuredData: new ZKStructuredData({ structuredData: [] }),
      signature: Buffer.from("test"),
      verificationData: await signerIdentity.getVerificationData(),
      signatureTimestamp: 123456,
      hasher: new KeccakHasher(),
    });
    const signerSignature = await signerIdentity.sign(
      (await signer.getRoot()).bigInt()
    );

    const originatorIdentity = new PrivateKeyIdentity({
      privateKey: "ORIGINATOR_PRIVATE_KEY",
      uniqueIdentifier: "originator@test.com",
      verificationData: { signature: "hi", message: "hi", publicKey: "hi" },
    });
    const originator = new ZKDocumentParticipant({
      documentId,
      initiator: true,
      role: ParticipantRole.ORIGINATOR,
      subrole: "",
      name: "Test Originator",
      uniqueIdentifier: await originatorIdentity.getUniqueIdentifier(),
      structuredData: new ZKStructuredData({ structuredData: [] }),
      signature: Buffer.from("test"),
      verificationData: await originatorIdentity.getVerificationData(),
      signatureTimestamp: 123456,
      hasher: new KeccakHasher(),
    });

    const originatorSignature = await originatorIdentity.sign(
      (await originator.getRoot()).bigInt()
    );

    const input = await getProofOfSignatureInputs({
      document: {
        title: "My Title",
        initiatorUniqueIdentifier: "test@test.com",
        type: DocumentType.AGREEMENT,
        pdf: await readFile("./fw9.pdf"),
        structuredData: [],
        encryptionKey: Buffer.from("a".repeat(32)),
      },
      logs: [
        {
          id: 1,
          documentId,
          smtRoot: 0,
          nonce: 0,
          verifiedParticipant: packSignature(originatorSignature),
        },
        {
          id: 2,
          documentId,
          smtRoot: 0,
          nonce: 0,
          verifiedParticipant: packSignature(signerSignature),
        },
      ],
      signer: {
        documentId,
        id: 2,
        initiator: false,
        role: ParticipantRole.SIGNER,
        subrole: "",
        name: "Test Signer",
        uniqueIdentifier: "signer@test.com",
        structuredData: [],
        signature: Buffer.from("test"),
        verificationData: {},
        signatureTimestamp: 123456,
      },
      originator: {
        documentId,
        id: 1,
        initiator: true,
        role: ParticipantRole.ORIGINATOR,
        subrole: "",
        name: "Test Originator",
        uniqueIdentifier: "originator@test.com",
        structuredData: [],
        signature: Buffer.from("test"),
        verificationData: {},
        signatureTimestamp: 123456,
      },
    });

    console.log(JSON.stringify(input, null, 2));

    const witness = await circuit.calculateWitness(input);
    await circuit.checkConstraints(witness);
  });
});

function packSignature(sig) {
  const packed = Eddsa.packSignature({
    R8: [sig.R8x, sig.R8y],
    S: sig.S,
  });

  return `0x${Buffer.from(packed).toString("hex")}`;
}
