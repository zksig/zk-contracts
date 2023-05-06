pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template DocumentIdPart(nLevels) {
  signal input documentId;
  signal input key;
  signal input value;
  signal input siblings[nLevels];

  component smt = SMTVerifier(nLevels);
  smt.enabled <== 1;
  smt.root <== documentId;
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
  var nLevels = 4;

  signal input documentId;

  signal input title;
  signal input titleSiblings[nLevels];

  signal input type;
  signal input typeSiblings[nLevels];

  signal input pdfCID;
  signal input pdfCIDSiblings[nLevels];

  signal input pageHash;
  signal input pageHashSiblings[nLevels];

  signal input fieldHash;
  signal input fieldHashSiblings[nLevels];

  signal input structuredDataHash;
  signal input structuredDataHashSiblings[nLevels];

  signal input encryptionKey;
  signal input encryptionKeySiblings[nLevels];

  component titleVerifier = DocumentIdPart(nLevels);
  titleVerifier.documentId <== documentId;
  titleVerifier.key <== 0;
  titleVerifier.value <== title;
  titleVerifier.siblings <== titleSiblings;

  component typeVerifier = DocumentIdPart(nLevels);
  typeVerifier.documentId <== documentId;
  typeVerifier.key <== 1;
  typeVerifier.value <== type;
  typeVerifier.siblings <== typeSiblings;

  component pdfCIDVerifier = DocumentIdPart(nLevels);
  pdfCIDVerifier.documentId <== documentId;
  pdfCIDVerifier.key <== 2;
  pdfCIDVerifier.value <== pdfCID;
  pdfCIDVerifier.siblings <== pdfCIDSiblings;

  component pageHashVerifier = DocumentIdPart(nLevels);
  pageHashVerifier.documentId <== documentId;
  pageHashVerifier.key <== 3;
  pageHashVerifier.value <== pageHash;
  pageHashVerifier.siblings <== pageHashSiblings;

  component fieldHashVerifier = DocumentIdPart(nLevels);
  fieldHashVerifier.documentId <== documentId;
  fieldHashVerifier.key <== 4;
  fieldHashVerifier.value <== fieldHash;
  fieldHashVerifier.siblings <== fieldHashSiblings;

  component structuredDataHashVerifier = DocumentIdPart(nLevels);
  structuredDataHashVerifier.documentId <== documentId;
  structuredDataHashVerifier.key <== 5;
  structuredDataHashVerifier.value <== structuredDataHash;
  structuredDataHashVerifier.siblings <== structuredDataHashSiblings;

  component encryptionKeyVerifier = DocumentIdPart(nLevels);
  encryptionKeyVerifier.documentId <== documentId;
  encryptionKeyVerifier.key <== 6;
  encryptionKeyVerifier.value <== encryptionKey;
  encryptionKeyVerifier.siblings <== encryptionKeySiblings;
}

