pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";

template AgreementSignatureMessage() {
  signal input name;
  signal input email;
  signal input identifier;
  signal input agreementId;
  signal input agreementPDF;
  signal input ipAddress;
  signal input timestamp;
  signal output M;

  component msg = Poseidon(7);
  msg.inputs[0] <== name;
  msg.inputs[1] <== email;
  msg.inputs[2] <== identifier;
  msg.inputs[3] <== agreementId;
  msg.inputs[4] <== agreementPDF;
  msg.inputs[5] <== ipAddress;
  msg.inputs[6] <== timestamp;

  M <== msg.out;
}
