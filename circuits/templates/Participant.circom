pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template ParticipantPart(nLevels) {
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

template Participant() {
  var nLevels = 5;

  signal input root;

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

  signal input verificationIPAddress;
  signal input verificationIPAddressSiblings[nLevels];
  
  signal input verificationMethod;
  signal input verificationMethodSiblings[nLevels];

  signal input verificationTimestamp;
  signal input verificationTimestampSiblings[nLevels];

  component documentIdVerifier = ParticipantPart(nLevels);
  documentIdVerifier.root <== root;
  documentIdVerifier.key <== 0;
  documentIdVerifier.value <== documentId;
  for(var i = 0; i < nLevels; i++) {
    documentIdVerifier.siblings[i] <== documentIdSiblings[i];
  }

  component initiatorVerifier = ParticipantPart(nLevels);
  initiatorVerifier.root <== root;
  initiatorVerifier.key <== 1;
  initiatorVerifier.value <== initiator;
  for(var i = 0; i < nLevels; i++) {
    initiatorVerifier.siblings[i] <== initiatorSiblings[i];
  }

  component roleVerifier = ParticipantPart(nLevels);
  roleVerifier.root <== root;
  roleVerifier.key <== 2;
  roleVerifier.value <== role;
  for(var i = 0; i < nLevels; i++) {
    roleVerifier.siblings[i] <== roleSiblings[i];
  }

  component subroleVerifier = ParticipantPart(nLevels);
  subroleVerifier.root <== root;
  subroleVerifier.key <== 3;
  subroleVerifier.value <== subrole;
  for(var i = 0; i < nLevels; i++) {
    subroleVerifier.siblings[i] <== subroleSiblings[i];
  }

  component nameVerifier = ParticipantPart(nLevels);
  nameVerifier.root <== root;
  nameVerifier.key <== 4;
  nameVerifier.value <== name;
  for(var i = 0; i < nLevels; i++) {
    nameVerifier.siblings[i] <== nameSiblings[i];
  }

  component uniqueIdentifierVerifier = ParticipantPart(nLevels);
  uniqueIdentifierVerifier.root <== root;
  uniqueIdentifierVerifier.key <== 5;
  uniqueIdentifierVerifier.value <== uniqueIdentifier;
  for(var i = 0; i < nLevels; i++) {
    uniqueIdentifierVerifier.siblings[i] <== uniqueIdentifierSiblings[i];
  }

  component verificationIPAddressVerifier = ParticipantPart(nLevels);
  verificationIPAddressVerifier.root <== root;
  verificationIPAddressVerifier.key <== 6;
  verificationIPAddressVerifier.value <== verificationIPAddress;
  for(var i = 0; i < nLevels; i++) {
    verificationIPAddressVerifier.siblings[i] <== verificationIPAddressSiblings[i];
  }

  component verificationMethodVerifier = ParticipantPart(nLevels);
  verificationMethodVerifier.root <== root;
  verificationMethodVerifier.key <== 7;
  verificationMethodVerifier.value <== verificationMethod;
  for(var i = 0; i < nLevels; i++) {
    verificationMethodVerifier.siblings[i] <== verificationMethodSiblings[i];
  }

  component verificationTimestampVerifier = ParticipantPart(nLevels);
  verificationTimestampVerifier.root <== root;
  verificationTimestampVerifier.key <== 8;
  verificationTimestampVerifier.value <== verificationTimestamp;
  for(var i = 0; i < nLevels; i++) {
    verificationTimestampVerifier.siblings[i] <== verificationTimestampSiblings[i];
  }
}
