const {
  newMemEmptyTrie,
  buildEddsa,
  buildPedersenHash,
} = require("circomlibjs");
const { wasm } = require("circom_tester");

describe("ProofOfSignature circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ProofOfSignature.circom");
  });

  it("passes if valid proof of signature is passed", async () => {
    const eddsa = await buildEddsa();
    const pedersen = await buildPedersenHash();

    const document = {
      title: getKey(pedersen.hash("Employment Agreement")),
      type: 0,
      structuredData:
        "6072778328777765686589340087799057556784077494424838987042795657960714018233",
      pdfCID:
        "92588233037783879563969273043159908070107399956055470360226357353108525156563",
      encryptedPDFCID:
        "92588233021354542797278455929580698293874520116291359088333709197636803149257",
      pdfHash:
        "10157129442320636078015441239429970930350473330240347321202968045414332801408",
      totalPages: "6",
      encryptionKey:
        "0xd0c8ba79582d79bd268c5d01bb7ba01794fe8d6c8841a11019141d4cada5402e",
    };

    const documentTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(document).entries()) {
      await documentTree.insert(i, value);
    }

    const originator = {
      documentId: documentTree.F.toObject(documentTree.root),
      initiator: 1,
      role: 0,
      subrole: 0,
      name: getKey(pedersen.hash("Test Originator")),
      uniqueIdentifier: getKey(pedersen.hash("originator@test.com")),
      verificationIPAddress: getKey(pedersen.hash("55.55.55.55")),
      verificationMethod: getKey(pedersen.hash("email")),
      verificationIPAddress: "1234567890",
    };

    const signer = {
      documentId: documentTree.F.toObject(documentTree.root),
      initiator: 0,
      role: 3,
      subrole: getKey(pedersen.hash("employee")),
      name: getKey(pedersen.hash("Test Signer")),
      uniqueIdentifier: getKey(pedersen.hash("signer@test.com")),
      verificationIPAddress: getKey(pedersen.hash("55.55.55.55")),
      verificationMethod: getKey(pedersen.hash("email")),
      verificationTimestamp: "9876543210",
    };

    const originatorParticipantTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(originator).entries()) {
      await originatorParticipantTree.insert(i, value);
    }

    const signerParticipantTree = await newMemEmptyTrie();
    for (const [i, value] of Object.values(signer).entries()) {
      await signerParticipantTree.insert(i, value);
    }

    const originatorPrivateKey = "ORIGINATOR_PRIVATE_KEY";
    const originatorPublicKey = eddsa.prv2pub(originatorPrivateKey);
    const originatorSig = eddsa.signPoseidon(
      originatorPrivateKey,
      originatorParticipantTree.root
    );

    const signerPrivateKey = "ORIGINATOR_PRIVATE_KEY";
    const signerPublicKey = eddsa.prv2pub(signerPrivateKey);
    const signerSig = eddsa.signPoseidon(
      signerPrivateKey,
      signerParticipantTree.root
    );

    const documentParticipantsTree = await newMemEmptyTrie();
    await documentParticipantsTree.insert(originatorSig.S, 0);
    await documentParticipantsTree.insert(signerSig.S, 0);
    for (let i = 0; i < 30; i++) {
      await documentParticipantsTree.insert(
        `22406528692252135119456532763175948575940741210963338630389976236458137077${i
          .toString()
          .padStart(2, "0")}`,
        0
      );
    }

    const witness = await circuit.calculateWitness({
      documentTitle: getKey(pedersen.hash("Employment Agreement")),
      documentTitleSiblings: await getSiblings(documentTree, 0),

      participantsRoot: documentParticipantsTree.F.toObject(
        documentParticipantsTree.root
      ),
      signerParticipantSiblings: await getSiblings(
        documentParticipantsTree,
        signerSig.S,
        20
      ),
      originatorParticipantSiblings: await getSiblings(
        documentParticipantsTree,
        originatorSig.S,
        20
      ),

      documentId: documentTree.F.toObject(documentTree.root),
      signerParticipantId: signerParticipantTree.F.toObject(
        signerParticipantTree.root
      ),
      signerName: getKey(pedersen.hash("Test Signer")),
      signerSubrole: getKey(pedersen.hash("employee")),
      signedAt: "9876543210",

      documentIdSiblings: await getSiblings(signerParticipantTree, 0),
      signerRoleSiblings: await getSiblings(signerParticipantTree, 2),
      signerNameSiblings: await getSiblings(signerParticipantTree, 4),
      signerSubroleSiblings: await getSiblings(signerParticipantTree, 3),
      signedAtSiblings: await getSiblings(signerParticipantTree, 8),

      originatorParticipantId: originatorParticipantTree.F.toObject(
        originatorParticipantTree.root
      ),
      originatorSignature: originatorSig.S,
      originatorName: getKey(pedersen.hash("Test Originator")),
      originatorUniqueIdentifier: getKey(pedersen.hash("originator@test.com")),
      originatorNameSiblings: await getSiblings(originatorParticipantTree, 4),
      originatorUniqueIdentifierSiblings: await getSiblings(
        originatorParticipantTree,
        5
      ),

      S: signerSig.S,
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
