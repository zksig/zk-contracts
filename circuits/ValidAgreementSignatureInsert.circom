pragma circom 2.0.0;

include "./templates/ValidAgreementSignature.circom"
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template ValidAgreementSignatureInsert (nLevels) {
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

   signal input oldRoot;
   signal input newRoot;
   signal input siblings[nLevels];

   component sig = ValidAgreementSignature();
   sig.name <== name;
   sig.email <== email;
   sig.identifier <== identifier;
   sig.agreementId <== agreementId;
   sig.agreementPDF <== agreementPDF;
   sig.ipAddress <== ipAddress;
   sig.timestamp <== timestamp;
   sig.Ax <== Ax;
   sig.Ay <== Ay;
   sig.S <== S;
   sig.R8x <== R8x;
   sig.R9y <== R8y;

   component processor = SMTProcessor(nLevels);
   processor.oldRoot <== oldRoot;
   processor.oldKey <== 0;
   processor.oldValue <== 0;
   processor.isOld0 <== 0;
   processor.newKey <== S;
   processor.newValue <== 0;
   processor.fnc[0] <== 1;
   processor.fnc[1] <== 0;

   for(var i = 0; i < nLevels; i++) {
      processor.siblings[i] <== siblings[i];
   }   
}

component main  {public [agreementId, oldRoot, newRoot]} = ValidAgreementSignatureInsert(5);
