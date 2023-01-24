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
   signal input agreementIdHash;
   signal input pageHash;
   signal input siblings[nLevels];

   component agreementId = AgreementId();
   agreementId.title <== title;
   agreementId.totalSigners <== totalSigners;
   agreementId.pdfCID <== pdfCID;
   agreementId.totalPages <== totalPages;
   agreementId.encryptionKey <== encryptionKey;
   agreementId.pdfHash <== pdfHash;

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
   
   agreementIdHash === agreementId.hash;
}

component main  {public [agreementIdHash, pageHash]} = ValidAgreementPage(10);
