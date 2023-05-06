pragma circom 2.0.0;

include "./templates/DocumentId.circom";
include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ValidStructuredDataItem(nLevels) {
  var documentIdLevels = 4;

  signal input documentId;

  signal input structuredDataHash;
  signal input structuredDataHashSiblings[documentIdLevels];

  signal input fieldName;
  signal input fieldValue;
  signal input fieldSiblings[nLevels];

  component validStructuredData = DocumentIdPart(documentIdLevels);
  validStructuredData.documentId <== documentId;
  validStructuredData.key <== 5;
  validStructuredData.value <== structuredDataHash;
  validStructuredData.siblings <== structuredDataHashSiblings;

  component smt = SMTVerifier(nLevels);
  smt.enabled <== 1;
  smt.root <== structuredDataHash;
  smt.oldKey <== 0;
  smt.oldValue <== 0;
  smt.isOld0 <== 0;
  smt.key <== fieldName;
  smt.value <== fieldValue;
  smt.fnc <== 0;
  smt.siblings <== fieldSiblings;
}

component main  {public [documentId, fieldName, fieldValue]} = ValidStructuredDataItem(20);
