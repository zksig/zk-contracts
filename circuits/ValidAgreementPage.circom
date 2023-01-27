pragma circom 2.0.0;

include "./templates/AgreementId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidAgreementPage (nLevels) {
   signal input pdfHash;
   signal input pdfHashSiblings[10];
   signal input agreementId;
   signal input pageHash;
   signal input siblings[nLevels];

   component pdfInAgreement = AgreementIdPart();
   pdfInAgreement.root <== agreementId;
   pdfInAgreement.key <== 31635587855381352;
   pdfInAgreement.value <== pdfHash;
   for(var i = 0; i < 10; i++) {
      pdfInAgreement.siblings[i] <== pdfHashSiblings[i];
   }


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
}

component main  {public [agreementId, pageHash]} = ValidAgreementPage(10);
