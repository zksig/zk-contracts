pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template AgreementIdPart() {
   signal input root;
   signal input key;
   signal input value;
   signal input siblings[10];

   component smt = SMTVerifier(10);
   smt.enabled <== 1;
   smt.root <== root;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== key;
   smt.value <== value;
   smt.fnc <== 0;
   for(var i = 0; i < 10; i++) {
      smt.siblings[i] <== siblings[i];
   }
}

template AgreementId () {
   signal input root;

   signal input title;
   signal input titleSiblings[10];

   signal input totalSigners;
   signal input totalSignersSiblings[10];

   signal input pdfCID;
   signal input pdfCIDSiblings[10];

   signal input pdfHash;
   signal input pdfHashSiblings[10];

   signal input totalPages;
   signal input totalPagesSiblings[10];

   signal input encryptionKey;
   signal input encryptionKeySiblings[10];

   component titleVerifier = AgreementIdPart();
   titleVerifier.root <== root;
   titleVerifier.key <== 499985443941;
   titleVerifier.value <== title;
   for(var i = 0; i < 10; i++) {
      titleVerifier.siblings[i] <== titleSiblings[i];
   }

   component totalSignersVerifier = AgreementIdPart();
   totalSignersVerifier.root <== root;
   totalSignersVerifier.key <== 36035001496905138311256175219;
   totalSignersVerifier.value <== totalSigners;
   for(var i = 0; i < 10; i++) {
      totalSignersVerifier.siblings[i] <== totalSignersSiblings[i];
   }

   component pdfCIDVerifier = AgreementIdPart();
   pdfCIDVerifier.root <== root;
   pdfCIDVerifier.key <== 123576514726212;
   pdfCIDVerifier.value <== pdfCID;
   for(var i = 0; i < 10; i++) {
      pdfCIDVerifier.siblings[i] <== pdfCIDSiblings[i];
   }

   component pdfHashVerifier = AgreementIdPart();
   pdfHashVerifier.root <== root;
   pdfHashVerifier.key <== 31635587855381352;
   pdfHashVerifier.value <== pdfHash;
   for(var i = 0; i < 10; i++) {
      pdfHashVerifier.siblings[i] <== pdfHashSiblings[i];
   }

   component totalPagesVerifier = AgreementIdPart();
   totalPagesVerifier.root <== root;
   totalPagesVerifier.key <== 549850486708134232941939;
   totalPagesVerifier.value <== totalPages;
   for(var i = 0; i < 10; i++) {
      totalPagesVerifier.siblings[i] <== totalPagesSiblings[i];
   }

   component encryptionKeyVerifier = AgreementIdPart();
   encryptionKeyVerifier.root <== root;
   encryptionKeyVerifier.key <== 8036207989267126200411230004601;
   encryptionKeyVerifier.value <== encryptionKey;
   for(var i = 0; i < 10; i++) {
      encryptionKeyVerifier.siblings[i] <== encryptionKeySiblings[i];
   }
}

