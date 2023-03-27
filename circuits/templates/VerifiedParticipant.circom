pragma circom 2.0.0;

include "./Participant.circom";
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";

template VerifiedParticipant() {
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

  signal input Ax; // first 32 bytes of public key
  signal input Ay; // second 32 bytes of public key
  signal input S;
  signal input R8x; // first 32 bytes of signature
  signal input R8y; // second 32 bytes of signature

  component participant = Participant();
  participant.participantId <== participantId;
  participant.documentId <== documentId;
  participant.documentIdSiblings <==documentIdSiblings;
  participant.initiator <== initiator;
  participant.initiatorSiblings <== initiatorSiblings;
  participant.role <== role;
  participant.roleSiblings <== roleSiblings;
  participant.subrole <== subrole;
  participant.subroleSiblings <== subroleSiblings;
  participant.name <== name;
  participant.nameSiblings <== nameSiblings;
  participant.uniqueIdentifier <== uniqueIdentifier;
  participant.uniqueIdentifierSiblings <== uniqueIdentifierSiblings;
  participant.structuredDataHash <== structuredDataHash;
  participant.structuredDataHashSiblings <== structuredDataHashSiblings;
  participant.verificationData <== verificationData;
  participant.verificationDataSiblings <== verificationDataSiblings;
  participant.signature <== signature;
  participant.signatureSiblings <== signatureSiblings;
  participant.signatureTimestamp <== signatureTimestamp;
  participant.signatureTimestampSiblings <== signatureTimestampSiblings;
  

  component sig = EdDSAPoseidonVerifier();
  sig.enabled <== 1;
  sig.Ax <== Ax;
  sig.Ay <== Ay;
  sig.S <== S;
  sig.R8x <== R8x;
  sig.R8y <== R8y;
  sig.M <== participantId;
}
