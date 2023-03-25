pragma circom 2.0.0;

include "./templates/VerifiedParticipantData.circom";
include "./templates/DocumentId.circom";

template ProofOfSignature() {
  var nLevels = 20;

  signal input documentTitle;
  signal input documentTitleSiblings[nLevels];

  signal input participantsRoot;
  signal input signerParticipantSiblings[20];
  signal input originatorParticipantSiblings[20];

  signal input documentId;
  signal input signerParticipantId;
  signal input signature;
  signal input signerSubrole;
  signal input signedAt;
  signal input documentIdSiblings[nLevels];
  signal input signerRoleSiblings[nLevels];
  signal input signatureSiblings[nLevels];
  signal input signerSubroleSiblings[nLevels];
  signal input signedAtSiblings[nLevels];

  signal input originatorParticipantId;
  signal input originatorSignature;
  signal input originatorName;
  signal input originatorUniqueIdentifier;
  signal input originatorNameSiblings[nLevels];
  signal input originatorUniqueIdentifierSiblings[nLevels];

  signal input S;

  // Verify signature is part of audit trail
  component signerSMT = SMTVerifier(20);
  signerSMT.enabled <== 1;
  signerSMT.root <== participantsRoot;
  signerSMT.oldKey <== 0;
  signerSMT.oldValue <== 0;
  signerSMT.isOld0 <== 0;
  signerSMT.key <== S;
  signerSMT.value <== 0;
  signerSMT.fnc <== 0;
  signerSMT.siblings <== signerParticipantSiblings;

  // Verify originator is part of audit trail
  component originatorSMT = SMTVerifier(20);
  originatorSMT.enabled <== 1;
  originatorSMT.root <== participantsRoot;
  originatorSMT.oldKey <== 0;
  originatorSMT.oldValue <== 0;
  originatorSMT.isOld0 <== 0;
  originatorSMT.key <== originatorSignature;
  originatorSMT.value <== 0;
  originatorSMT.fnc <== 0;
  originatorSMT.siblings <== originatorParticipantSiblings;


  // Check document title
  component validDocumentTitle = DocumentIdPart(nLevels);
  validDocumentTitle.root <== documentId;
  validDocumentTitle.key <== 0;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check document ID
  component validDocumentId = ParticipantPart(nLevels);
  validDocumentId.root <== signerParticipantId;
  validDocumentId.key <== 0;
  validDocumentId.value <== documentId;
  validDocumentId.siblings <== documentIdSiblings;

  // Check they are a signer
  component participantIsSigner = ParticipantPart(nLevels);
  participantIsSigner.root <== signerParticipantId;
  participantIsSigner.key <== 2;
  participantIsSigner.value <== 3;
  participantIsSigner.siblings <== signerRoleSiblings;

  // Check the name of the signer
  component validSignerName = ParticipantPart(nLevels);
  validSignerName.root <== signerParticipantId;
  validSignerName.key <== 4;
  validSignerName.value <== signerName;
  validSignerName.siblings <== signerNameSiblings;

  // Check the subrole of the signer
  component validSignerSubrole = ParticipantPart(nLevels);
  validSignerSubrole.root <== signerParticipantId;
  validSignerSubrole.key <== 3;
  validSignerSubrole.value <== signerSubrole;
  validSignerSubrole.siblings <== signerSubroleSiblings;

  // Check the time of signature
  component validSignedAtTime = ParticipantPart(nLevels);
  validSignedAtTime.root <== signerParticipantId;
  validSignedAtTime.key <== 8;
  validSignedAtTime.value <== signedAt;
  validSignedAtTime.siblings <== signedAtSiblings;

  // Check originator name
  component validOriginatorName = ParticipantPart(nLevels);
  validOriginatorName.root <== originatorParticipantId;
  validOriginatorName.key <== 4;
  validOriginatorName.value <== originatorName;
  validOriginatorName.siblings <== originatorNameSiblings;

  // Check originator unique identifier
  component validOriginatorUniqueIdentifier = ParticipantPart(nLevels);
  validOriginatorUniqueIdentifier.root <== originatorParticipantId;
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
