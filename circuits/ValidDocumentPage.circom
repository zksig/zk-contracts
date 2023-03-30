pragma circom 2.0.0;

include "./templates/DocumentId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidAgreementPage (nLevels) {
   signal input documentId;

   signal input pageHash;
   signal input pageHashSiblings[20];

   signal input pageNumber;
   signal input page;
   signal input pageSiblings[nLevels];

   component pdfInDocument = DocumentIdPart(20);
   pdfInDocument.documentId <== documentId;
   pdfInDocument.key <== 19286320604300090977313927851360922220698906380410397735753243249770147293983;
   pdfInDocument.value <== pageHash;
   pdfInDocument.siblings <== pageHashSiblings;

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.fnc <== 0;
   smt.root <== pageHash;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== pageNumber;
   smt.value <== page;
   smt.siblings <== pageSiblings;
}

component main  {public [documentId, page]} = ValidAgreementPage(20);
