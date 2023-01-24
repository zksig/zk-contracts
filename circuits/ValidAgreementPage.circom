pragma circom 2.0.0;

include "./templates/AgreementId.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidAgreementPage (nLevels) {
   signal input title;
   signal input totalSigners;
   signal input pdfCID;
   signal input pdfHash;
   signal input totalPages;
   signal input encryptionKey;
   signal input agreementId;
   signal input pageHash;
   signal input siblings[nLevels];

   component id = AgreementId();
   id.title <== title;
   id.totalSigners <== totalSigners;
   id.pdfCID <== pdfCID;
   id.totalPages <== totalPages;
   id.encryptionKey <== encryptionKey;
   id.pdfHash <== pdfHash;

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.fnc <== 0;
   smt.root <== pdfHash;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== pageHash;
   smt.value <== 0;
   for(var i = 0; i < nLevels; i++) {
      smt.siblings[i] <== siblings[i];
   }
   
   agreementId === id.hash;
}

component main  {public [agreementId, pageHash]} = ValidAgreementPage(10);
