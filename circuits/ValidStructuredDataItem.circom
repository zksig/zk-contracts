pragma circom 2.0.0;

include "./templates/DocumentId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidStructuredDataItem() {
   var nLevels = 9;
   var documentIdLevels = 20;

   signal input id;

   signal input title;
   signal input titleSiblings[documentIdLevels];

   signal input type;
   signal input typeSiblings[documentIdLevels];

   signal input structuredData;
   signal input structuredDataSiblings[documentIdLevels];

   signal input pdfCID;
   signal input pdfCIDSiblings[documentIdLevels];

   signal input encryptedPDFCID;
   signal input encryptedPDFCIDSiblings[documentIdLevels];

   signal input pdfHash;
   signal input pdfHashSiblings[documentIdLevels];

   signal input totalPages;
   signal input totalPagesSiblings[documentIdLevels];

   signal input encryptionKey;
   signal input encryptionKeySiblings[documentIdLevels];

   signal input key;
   signal input itemHash;
   signal input siblings[nLevels];

   component documentId = DocumentId();
   documentId.id <== id;
   documentId.title <== title;
   documentId.titleSiblings <== titleSiblings;
   documentId.type <== type;
   documentId.typeSiblings <== typeSiblings;
   documentId.structuredData <== structuredData;
   documentId.structuredDataSiblings <== structuredDataSiblings;
   documentId.pdfCID <== pdfCID;
   documentId.pdfCIDSiblings <== pdfCIDSiblings;
   documentId.encryptedPDFCID <== encryptedPDFCID;
   documentId.encryptedPDFCIDSiblings <== encryptedPDFCIDSiblings;
   documentId.pdfHash <== pdfHash;
   documentId.pdfHashSiblings <== pdfHashSiblings;
   documentId.totalPages <== totalPages;
   documentId.totalPagesSiblings <== totalPagesSiblings;
   documentId.encryptionKey <== encryptionKey;
   documentId.encryptionKeySiblings <== encryptionKeySiblings;

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.root <== structuredData;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== key;
   smt.value <== itemHash;
   smt.fnc <== 0;
   smt.siblings <== siblings;
}

component main  {public [id, itemHash]} = ValidStructuredDataItem();
