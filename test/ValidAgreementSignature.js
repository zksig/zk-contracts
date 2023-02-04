const { wasm } = require("circom_tester");
const { buildEddsa, buildPoseidon } = require("circomlibjs");

describe("ValidAgreementSignature circuit", () => {
  let circuit;
  before(async () => {
    circuit = await wasm("./circuits/ValidAgreementSignature.circom");
  });

  it("passes if valid signature", async () => {
    const poseidon = await buildPoseidon();
    const eddsa = await buildEddsa();

    const name = stringToDecimal("test test");
    const email = stringToDecimal("test@test.com");
    const identifier = stringToDecimal("manager");
    const agreementId = "1234";
    const pdfHash = "9876";
    const ipAddress = stringToDecimal("55.55.55.55");
    const timestamp = "1234565678";

    const msg = poseidon([
      name,
      email,
      identifier,
      agreementId,
      pdfHash,
      ipAddress,
      timestamp,
    ]);

    const privateKey = "PRIVATE_KEY";
    const publicKey = eddsa.prv2pub(privateKey);
    const sig = eddsa.signPoseidon(privateKey, msg);

    const witness = await circuit.calculateWitness({
      name,
      email,
      identifier,
      agreementId,
      pdfHash,
      ipAddress,
      timestamp,
      Ax: eddsa.F.toObject(publicKey[0]),
      Ay: eddsa.F.toObject(publicKey[1]),
      S: sig.S,
      R8x: eddsa.F.toObject(sig.R8[0]),
      R8y: eddsa.F.toObject(sig.R8[1]),
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
