pragma circom 2.0.0;

include "./templates/DocumentId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidAgreementPage (nLevels) {
   signal input pdfHash;
   signal input pdfHashSiblings[5];
   signal input documentId;
   signal input pageHash;
   signal input siblings[nLevels];

   component pdfInDocument = DocumentIdPart(5);
   pdfInDocument.root <== documentId;
   pdfInDocument.key <== 5;
   pdfInDocument.value <== pdfHash;
   pdfInDocument.siblings <== pdfHashSiblings;

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.fnc <== 0;
   smt.root <== pdfHash;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== pageHash;
   smt.value <== 0;
   smt.siblings <== siblings;
}

component main  {public [documentId, pageHash]} = ValidAgreementPage(20);
