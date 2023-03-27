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
  var nLevels = 20;

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
  documentIdVerifier.key <== 8431889515165275580762257512939684954742032291406494228537853067122239678810;
  documentIdVerifier.value <== documentId;
  documentIdVerifier.siblings <== documentIdSiblings;

  component initiatorVerifier = ParticipantPart(nLevels);
  initiatorVerifier.participantId <== participantId;
  initiatorVerifier.key <== 3709885633830081566047994396455016445829673180898220600869737471859249001309;
  initiatorVerifier.value <== initiator;
  initiatorVerifier.siblings <== initiatorSiblings;

  component roleVerifier = ParticipantPart(nLevels);
  roleVerifier.participantId <== participantId;
  roleVerifier.key <== 11269517948155635376213693597819113339197053678655097944624529865084209109078;
  roleVerifier.value <== role;
  roleVerifier.siblings <== roleSiblings;

  component subroleVerifier = ParticipantPart(nLevels);
  subroleVerifier.participantId <== participantId;
  subroleVerifier.key <== 16299433002785143980785024108122603391010504946311676740598659110368739073883;
  subroleVerifier.value <== subrole;
  subroleVerifier.siblings <== subroleSiblings;

  component nameVerifier = ParticipantPart(nLevels);
  nameVerifier.participantId <== participantId;
  nameVerifier.key <== 16570118920422897531023558127282308742513448349602829241232723598917494421360;
  nameVerifier.value <== name;
  nameVerifier.siblings <== nameSiblings;

  component uniqueIdentifierVerifier = ParticipantPart(nLevels);
  uniqueIdentifierVerifier.participantId <== participantId;
  uniqueIdentifierVerifier.key <== 21465088586070471274951294489004552887188904420374198958621133391059441710623;
  uniqueIdentifierVerifier.value <== uniqueIdentifier;
  uniqueIdentifierVerifier.siblings <== uniqueIdentifierSiblings;

  component structuredDataHashVerifier = ParticipantPart(nLevels);
  structuredDataHashVerifier.participantId <== participantId;
  structuredDataHashVerifier.key <== 17273568901141502150318856877583604888316741110871333618239496113149740467454;
  structuredDataHashVerifier.value <== structuredDataHash;
  structuredDataHashVerifier.siblings <== structuredDataHashSiblings;

  component verificationDataVerifier = ParticipantPart(nLevels);
  verificationDataVerifier.participantId <== participantId;
  verificationDataVerifier.key <== 21416308081959123630713624659288605919484559073851801332251071305287646772437;
  verificationDataVerifier.value <== verificationData;
  verificationDataVerifier.siblings <== verificationDataSiblings;

  component signatureVerifier = ParticipantPart(nLevels);
  signatureVerifier.participantId <== participantId;
  signatureVerifier.key <== 10253145063120662839141647369770603609160117995911816203872847534523035841457;
  signatureVerifier.value <== signature;
  signatureVerifier.siblings <== signatureSiblings;

  component signatureTimestampVerifier = ParticipantPart(nLevels);
  signatureTimestampVerifier.participantId <== participantId;
  signatureTimestampVerifier.key <== 21011016260274858177081918669366744293122895169804160264545088051997131465628;
  signatureTimestampVerifier.value <== signatureTimestamp;
  signatureTimestampVerifier.siblings <== signatureTimestampSiblings;
}
