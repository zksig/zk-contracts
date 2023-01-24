const { wasm } = require("circom_tester");
const { buildEddsa, buildPoseidon, newMemEmptyTrie } = require("circomlibjs");

describe("ValidAgreementSignatureInsert circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidAgreementSignatureInsert.circom");
  });

  it("passes if valid signature insert", async () => {
    const poseidon = await buildPoseidon();
    const eddsa = await buildEddsa();

    const name = stringToDecimal("test test");
    const email = stringToDecimal("test@test.com");
    const identifier = stringToDecimal("manager");
    const agreementId = "1234";
    const agreementPDF = "9876";
    const ipAddress = stringToDecimal("55.55.55.55");
    const timestamp = "1234565678";

    const msg = poseidon([
      name,
      email,
      identifier,
      agreementId,
      agreementPDF,
      ipAddress,
      timestamp,
    ]);

    const privateKey = "PRIVATE_KEY";
    const publicKey = eddsa.prv2pub(privateKey);
    const sig = eddsa.signPoseidon(privateKey, msg);

    const tree = await newMemEmptyTrie();
    await tree.insert(2, 0);
    await tree.insert(1, 0);
    await tree.insert(3, 0);
    await tree.insert(4, 0);

    const { oldRoot, siblings, newRoot, oldKey } = await tree.insert(sig.S, 0);
    const siblingHashes = siblings.map((s) => tree.F.toObject(s));
    while (siblingHashes.length < 5) siblingHashes.push(0);

    const witness = await circuit.calculateWitness({
      name,
      email,
      identifier,
      agreementId,
      agreementPDF,
      ipAddress,
      timestamp,
      Ax: eddsa.F.toObject(publicKey[0]),
      Ay: eddsa.F.toObject(publicKey[1]),
      S: sig.S,
      R8x: eddsa.F.toObject(sig.R8[0]),
      R8y: eddsa.F.toObject(sig.R8[1]),
      oldRoot: tree.F.toObject(oldRoot),
      oldKey: tree.F.toObject(oldKey),
      newRoot: tree.F.toObject(newRoot),
      siblings: siblingHashes,
    });

    await circuit.checkConstraints(witness);
  });
});

function stringToDecimal(str) {
  return hexToDecimal(Buffer.from(str).toString("hex"));
}

function hexToDecimal(hex) {
  return parseInt(hex, 16);
}
