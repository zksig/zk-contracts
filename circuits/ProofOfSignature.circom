pragma circom 2.0.0;

include "./templates/VerifiedParticipantData.circom";
include "./templates/DocumentId.circom";

template ProofOfSignature() {
  var documentIdLevels = 4;
  var participantIdLevels = 5;

  signal input documentTitle;
  signal input documentTitleSiblings[documentIdLevels];

  signal input participantsRoot;
  signal input signerSignedParticipantId;
  signal input signerSignedParticipantIdSiblings[20];
  signal input originatorSignedParticipantId;
  signal input originatorSignedParticipantIdSiblings[20];

  signal input signerParticipantId;
  signal input documentId;
  signal input signerSubrole;
  signal input signerName;
  signal input signedAt;
  signal input documentIdSiblings[participantIdLevels];
  signal input signerRoleSiblings[participantIdLevels];
  signal input signerSubroleSiblings[participantIdLevels];
  signal input signerNameSiblings[participantIdLevels];
  signal input signedAtSiblings[participantIdLevels];

  signal input originatorParticipantId;
  signal input originatorName;
  signal input originatorUniqueIdentifier;
  signal input originatorNameSiblings[participantIdLevels];
  signal input originatorUniqueIdentifierSiblings[participantIdLevels];

  // Verify signature is part of audit trail
  component signerSMT = SMTVerifier(20);
  signerSMT.enabled <== 1;
  signerSMT.root <== participantsRoot;
  signerSMT.oldKey <== 0;
  signerSMT.oldValue <== 0;
  signerSMT.isOld0 <== 0;
  signerSMT.key <== signerSignedParticipantId;
  signerSMT.value <== 0;
  signerSMT.fnc <== 0;
  signerSMT.siblings <== signerSignedParticipantIdSiblings;

  // Verify originator is part of audit trail
  component originatorSMT = SMTVerifier(20);
  originatorSMT.enabled <== 1;
  originatorSMT.root <== participantsRoot;
  originatorSMT.oldKey <== 0;
  originatorSMT.oldValue <== 0;
  originatorSMT.isOld0 <== 0;
  originatorSMT.key <== originatorSignedParticipantId;
  originatorSMT.value <== 0;
  originatorSMT.fnc <== 0;
  originatorSMT.siblings <== originatorSignedParticipantIdSiblings;


  // Check document title
  component validDocumentTitle = DocumentIdPart(documentIdLevels);
  validDocumentTitle.documentId <== documentId;
  validDocumentTitle.key <== 0;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check document ID
  component validDocumentId = ParticipantPart(participantIdLevels);
  validDocumentId.participantId <== signerParticipantId;
  validDocumentId.key <== 0;
  validDocumentId.value <== documentId;
  validDocumentId.siblings <== documentIdSiblings;

  // Check they are a signer
  component participantIsSigner = ParticipantPart(participantIdLevels);
  participantIsSigner.participantId <== signerParticipantId;
  participantIsSigner.key <== 2;
  participantIsSigner.value <== 3;
  participantIsSigner.siblings <== signerRoleSiblings;

  // Check the name of the signer
  component validSignerName = ParticipantPart(participantIdLevels);
  validSignerName.participantId <== signerParticipantId;
  validSignerName.key <== 4;
  validSignerName.value <== signerName;
  validSignerName.siblings <== signerNameSiblings;

  // Check the subrole of the signer
  component validSignerSubrole = ParticipantPart(participantIdLevels);
  validSignerSubrole.participantId <== signerParticipantId;
  validSignerSubrole.key <== 3;
  validSignerSubrole.value <== signerSubrole;
  validSignerSubrole.siblings <== signerSubroleSiblings;

  // Check the time of signature
  component validSignedAtTime = ParticipantPart(participantIdLevels);
  validSignedAtTime.participantId <== signerParticipantId;
  validSignedAtTime.key <== 9;
  validSignedAtTime.value <== signedAt;
  validSignedAtTime.siblings <== signedAtSiblings;

  // Check originator name
  component validOriginatorName = ParticipantPart(participantIdLevels);
  validOriginatorName.participantId <== originatorParticipantId;
  validOriginatorName.key <== 4;
  validOriginatorName.value <== originatorName;
  validOriginatorName.siblings <== originatorNameSiblings;

  // Check originator unique identifier
  component validOriginatorUniqueIdentifier = ParticipantPart(participantIdLevels);
  validOriginatorUniqueIdentifier.participantId <== originatorParticipantId;
  validOriginatorUniqueIdentifier.key <== 5;
  validOriginatorUniqueIdentifier.value <== originatorUniqueIdentifier;
  validOriginatorUniqueIdentifier.siblings <== originatorUniqueIdentifierSiblings;
}

component main  {public [
  documentId,
  participantsRoot,
  documentTitle,
  signerName,
  signerSubrole,
  signedAt,
  originatorName,
  originatorUniqueIdentifier
]} = ProofOfSignature();
