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

    const name = stringToDecimal("test test", eddsa.F);
    const email = stringToDecimal("test@test.com", eddsa.F);
    const identifier = stringToDecimal("manager", eddsa.F);
    const agreementId =
      "15672289171331961726174349807060979975311854093145864462589715964709036733829";
    const agreementPDF =
      "13447170627293990149299743736637736044191141457400194191392195792195628196501";
    const ipAddress = stringToDecimal("55.55.55.55", eddsa.F);
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
    const { oldRoot, siblings, newRoot, oldKey, isOld0 } = await tree.insert(
      sig.S,
      0
    );
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
      isOld0: isOld0 ? 1 : 0,
      siblings: siblingHashes,
    });

    await circuit.checkConstraints(witness);
  });
});

function stringToDecimal(str, F) {
  return F.toObject(Buffer.from(str));
}

function hexToDecimal(hex) {
  return parseInt(hex, 16);
}
