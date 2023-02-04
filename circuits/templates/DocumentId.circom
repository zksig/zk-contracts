pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template DocumentIdPart(nLevels) {
   signal input root;
   signal input key;
   signal input value;
   signal input siblings[nLevels];

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.root <== root;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== key;
   smt.value <== value;
   smt.fnc <== 0;
   for(var i = 0; i < nLevels; i++) {
      smt.siblings[i] <== siblings[i];
   }
}

template DocumentId () {
   var nLevels = 5;

   signal input id;

   signal input title;
   signal input titleSiblings[nLevels];

   signal input type;
   signal input typeSiblings[nLevels];

   signal input structuredData;
   signal input structuredDataSiblings[nLevels];

   signal input pdfCID;
   signal input pdfCIDSiblings[nLevels];

   signal input encryptedPDFCID;
   signal input encryptedPDFCIDSiblings[nLevels];

   signal input pdfHash;
   signal input pdfHashSiblings[nLevels];

   signal input totalPages;
   signal input totalPagesSiblings[nLevels];

   signal input encryptionKey;
   signal input encryptionKeySiblings[nLevels];

   component titleVerifier = DocumentIdPart(nLevels);
   titleVerifier.root <== id;
   titleVerifier.key <== 0;
   titleVerifier.value <== title;
   for(var i = 0; i < nLevels; i++) {
      titleVerifier.siblings[i] <== titleSiblings[i];
   }

   component typeVerifier = DocumentIdPart(nLevels);
   typeVerifier.root <== id;
   typeVerifier.key <== 1;
   typeVerifier.value <== type;
   for(var i = 0; i < nLevels; i++) {
      typeVerifier.siblings[i] <== typeSiblings[i];
   }

   component structuredDataVerifier = DocumentIdPart(nLevels);
   structuredDataVerifier.root <== id;
   structuredDataVerifier.key <== 2;
   structuredDataVerifier.value <== structuredData;
   for(var i = 0; i < nLevels; i++) {
      structuredDataVerifier.siblings[i] <== structuredDataSiblings[i];
   }

   component pdfCIDVerifier = DocumentIdPart(nLevels);
   pdfCIDVerifier.root <== id;
   pdfCIDVerifier.key <== 3;
   pdfCIDVerifier.value <== pdfCID;
   for(var i = 0; i < nLevels; i++) {
      pdfCIDVerifier.siblings[i] <== pdfCIDSiblings[i];
   }

   component encryptedPDFCIDVerifier = DocumentIdPart(nLevels);
   encryptedPDFCIDVerifier.root <== id;
   encryptedPDFCIDVerifier.key <== 4;
   encryptedPDFCIDVerifier.value <== encryptedPDFCID;
   for(var i = 0; i < nLevels; i++) {
      encryptedPDFCIDVerifier.siblings[i] <== encryptedPDFCIDSiblings[i];
   }

   component pdfHashVerifier = DocumentIdPart(nLevels);
   pdfHashVerifier.root <== id;
   pdfHashVerifier.key <== 5;
   pdfHashVerifier.value <== pdfHash;
   for(var i = 0; i < nLevels; i++) {
      pdfHashVerifier.siblings[i] <== pdfHashSiblings[i];
   }

   component totalPagesVerifier = DocumentIdPart(nLevels);
   totalPagesVerifier.root <== id;
   totalPagesVerifier.key <== 6;
   totalPagesVerifier.value <== totalPages;
   for(var i = 0; i < nLevels; i++) {
      totalPagesVerifier.siblings[i] <== totalPagesSiblings[i];
   }

   component encryptionKeyVerifier = DocumentIdPart(nLevels);
   encryptionKeyVerifier.root <== id;
   encryptionKeyVerifier.key <== 7;
   encryptionKeyVerifier.value <== encryptionKey;
   for(var i = 0; i < nLevels; i++) {
      encryptionKeyVerifier.siblings[i] <== encryptionKeySiblings[i];
   }
}

