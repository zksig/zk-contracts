pragma circom 2.0.0;

include "./templates/VerifiedParticipantData.circom";
include "./templates/DocumentId.circom";

template ProofOfSignature() {
  var nLevels = 20;

  signal input documentTitle;
  signal input documentTitleSiblings[nLevels];

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
  signal input documentIdSiblings[nLevels];
  signal input signerRoleSiblings[nLevels];
  signal input signerSubroleSiblings[nLevels];
  signal input signerNameSiblings[nLevels];
  signal input signedAtSiblings[nLevels];

  signal input originatorParticipantId;
  signal input originatorName;
  signal input originatorUniqueIdentifier;
  signal input originatorNameSiblings[nLevels];
  signal input originatorUniqueIdentifierSiblings[nLevels];

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
  component validDocumentTitle = DocumentIdPart(nLevels);
  validDocumentTitle.documentId <== documentId;
  validDocumentTitle.key <== 2139904204642469210661998095148174100843820818705209080323729726810569655635;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check document ID
  component validDocumentId = ParticipantPart(nLevels);
  validDocumentId.participantId <== signerParticipantId;
  validDocumentId.key <== 8431889515165275580762257512939684954742032291406494228537853067122239678810;
  validDocumentId.value <== documentId;
  validDocumentId.siblings <== documentIdSiblings;

  // Check they are a signer
  component participantIsSigner = ParticipantPart(nLevels);
  participantIsSigner.participantId <== signerParticipantId;
  participantIsSigner.key <== 11269517948155635376213693597819113339197053678655097944624529865084209109078;
  participantIsSigner.value <== 3;
  participantIsSigner.siblings <== signerRoleSiblings;

  // Check the name of the signer
  component validSignerName = ParticipantPart(nLevels);
  validSignerName.participantId <== signerParticipantId;
  validSignerName.key <== 16570118920422897531023558127282308742513448349602829241232723598917494421360;
  validSignerName.value <== signerName;
  validSignerName.siblings <== signerNameSiblings;

  // Check the subrole of the signer
  component validSignerSubrole = ParticipantPart(nLevels);
  validSignerSubrole.participantId <== signerParticipantId;
  validSignerSubrole.key <== 16299433002785143980785024108122603391010504946311676740598659110368739073883;
  validSignerSubrole.value <== signerSubrole;
  validSignerSubrole.siblings <== signerSubroleSiblings;

  // Check the time of signature
  component validSignedAtTime = ParticipantPart(nLevels);
  validSignedAtTime.participantId <== signerParticipantId;
  validSignedAtTime.key <== 21011016260274858177081918669366744293122895169804160264545088051997131465628;
  validSignedAtTime.value <== signedAt;
  validSignedAtTime.siblings <== signedAtSiblings;

  // Check originator name
  component validOriginatorName = ParticipantPart(nLevels);
  validOriginatorName.participantId <== originatorParticipantId;
  validOriginatorName.key <== 16570118920422897531023558127282308742513448349602829241232723598917494421360;
  validOriginatorName.value <== originatorName;
  validOriginatorName.siblings <== originatorNameSiblings;

  // Check originator unique identifier
  component validOriginatorUniqueIdentifier = ParticipantPart(nLevels);
  validOriginatorUniqueIdentifier.participantId <== originatorParticipantId;
  validOriginatorUniqueIdentifier.key <== 21465088586070471274951294489004552887188904420374198958621133391059441710623;
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
