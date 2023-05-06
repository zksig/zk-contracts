pragma circom 2.0.0;

include "./templates/DocumentId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidDocumentPage (nLevels) {
   signal input documentId;

   signal input pageHash;
   signal input pageHashSiblings[4];

   signal input pageNumber;
   signal input page;
   signal input pageSiblings[nLevels];

   component pdfInDocument = DocumentIdPart(4);
   pdfInDocument.documentId <== documentId;
   pdfInDocument.key <== 3;
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

component main  {public [documentId, page]} = ValidDocumentPage(20);
