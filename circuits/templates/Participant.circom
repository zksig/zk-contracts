pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ParticipantPart(nLevels) {
  signal input participantId;
  signal input key;
  signal input value;
  signal input siblings[nLevels];

  component smt = SMTVerifier(nLevels);
  smt.enabled <== 1;
  smt.root <== participantId;
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

template Participant() {
  var nLevels = 5;

  signal input participantId;

  signal input documentId;
  signal input documentIdSiblings[nLevels];

  signal input initiator;
  signal input initiatorSiblings[nLevels];

  signal input role;
  signal input roleSiblings[nLevels];

  signal input subrole;
  signal input subroleSiblings[nLevels];

  signal input name;
  signal input nameSiblings[nLevels];

  signal input uniqueIdentifier;
  signal input uniqueIdentifierSiblings[nLevels];

  signal input structuredDataHash;
  signal input structuredDataHashSiblings[nLevels];

  signal input verificationData;
  signal input verificationDataSiblings[nLevels];

  signal input signature;
  signal input signatureSiblings[nLevels];

  signal input signatureTimestamp;
  signal input signatureTimestampSiblings[nLevels];

  component documentIdVerifier = ParticipantPart(nLevels);
  documentIdVerifier.participantId <== participantId;
  documentIdVerifier.key <== 0;
  documentIdVerifier.value <== documentId;
  documentIdVerifier.siblings <== documentIdSiblings;

  component initiatorVerifier = ParticipantPart(nLevels);
  initiatorVerifier.participantId <== participantId;
  initiatorVerifier.key <== 1;
  initiatorVerifier.value <== initiator;
  initiatorVerifier.siblings <== initiatorSiblings;

  component roleVerifier = ParticipantPart(nLevels);
  roleVerifier.participantId <== participantId;
  roleVerifier.key <== 2;
  roleVerifier.value <== role;
  roleVerifier.siblings <== roleSiblings;

  component subroleVerifier = ParticipantPart(nLevels);
  subroleVerifier.participantId <== participantId;
  subroleVerifier.key <== 3;
  subroleVerifier.value <== subrole;
  subroleVerifier.siblings <== subroleSiblings;

  component nameVerifier = ParticipantPart(nLevels);
  nameVerifier.participantId <== participantId;
  nameVerifier.key <== 4;
  nameVerifier.value <== name;
  nameVerifier.siblings <== nameSiblings;

  component uniqueIdentifierVerifier = ParticipantPart(nLevels);
  uniqueIdentifierVerifier.participantId <== participantId;
  uniqueIdentifierVerifier.key <== 5;
  uniqueIdentifierVerifier.value <== uniqueIdentifier;
  uniqueIdentifierVerifier.siblings <== uniqueIdentifierSiblings;

  component structuredDataHashVerifier = ParticipantPart(nLevels);
  structuredDataHashVerifier.participantId <== participantId;
  structuredDataHashVerifier.key <== 6;
  structuredDataHashVerifier.value <== structuredDataHash;
  structuredDataHashVerifier.siblings <== structuredDataHashSiblings;

  component verificationDataVerifier = ParticipantPart(nLevels);
  verificationDataVerifier.participantId <== participantId;
  verificationDataVerifier.key <== 7;
  verificationDataVerifier.value <== verificationData;
  verificationDataVerifier.siblings <== verificationDataSiblings;

  component signatureVerifier = ParticipantPart(nLevels);
  signatureVerifier.participantId <== participantId;
  signatureVerifier.key <== 8;
  signatureVerifier.value <== signature;
  signatureVerifier.siblings <== signatureSiblings;

  component signatureTimestampVerifier = ParticipantPart(nLevels);
  signatureTimestampVerifier.participantId <== participantId;
  signatureTimestampVerifier.key <== 9;
  signatureTimestampVerifier.value <== signatureTimestamp;
  signatureTimestampVerifier.siblings <== signatureTimestampSiblings;
}
