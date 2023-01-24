pragma circom 2.0.0;

include "./AgreementSignatureMessage.circom";
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";

template ValidAgreementSignature() {
   signal input name;
   signal input email;
   signal input identifier;
   signal input agreementId;
   signal input agreementPDF;
   signal input ipAddress;
   signal input timestamp;
   signal input Ax; // first 32 bytes of public key
   signal input Ay; // second 32 bytes of public key
   signal input S;
   signal input R8x; // first 32 bytes of signature
   signal input R8y; // second 32 bytes of signature

   component msg = AgreementSignatureMessage();
   msg.name <== name;
   msg.email <== email;
   msg.identifier <== identifier;
   msg.agreementId <== agreementId;
   msg.agreementPDF <== agreementPDF;
   msg.ipAddress <== ipAddress;
   msg.timestamp <== timestamp;

   component sig = EdDSAPoseidonVerifier();
   sig.Ax <== Ax;
   sig.Ay <== Ay;
   sig.S <== S;
   sig.R8x <== R8x;
   sig.R8y <== R8y;
   sig.M <== msg.M;
}

component main  {public [agreementId, S, R8x, R8y]} = ValidAgreementSignature();
