pragma circom 2.0.0;

include "./templates/VerifiedParticipant.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template ValidDocumentVerifierInsert (nLevels) {
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

   signal input Ax; // first 32 bytes of public key
   signal input Ay; // second 32 bytes of public key
   signal input S;
   signal input R8x; // first 32 bytes of signature
   signal input R8y; // second 32 bytes of signature

   signal input oldRoot;
   signal input oldKey;
   signal input newRoot;
   signal input isOld0;
   signal input siblings[nLevels];

   component participantSig = VerifiedParticipant();
   participantSig.root <== root;
   participantSig.documentId <== documentId;
   participantSig.documentIdSiblings <== documentIdSiblings;
   participantSig.initiator <== initiator;
   participantSig.initiatorSiblings <== initiatorSiblings;
   participantSig.role <== role;
   participantSig.roleSiblings <== roleSiblings;
   participantSig.subrole <== subrole;
   participantSig.subroleSiblings <== subroleSiblings;
   participantSig.name <== name;
   participantSig.nameSiblings <== nameSiblings;
   participantSig.uniqueIdentifier <== uniqueIdentifier;
   participantSig.uniqueIdentifierSiblings <== uniqueIdentifierSiblings;
   participantSig.verificationIPAddress <== verificationIPAddress;
   participantSig.verificationIPAddressSiblings <== verificationIPAddressSiblings;
   participantSig.verificationMethod <== verificationMethod;
   participantSig.verificationMethodSiblings <== verificationMethodSiblings;
   participantSig.verificationTimestamp <== verificationTimestamp;
   participantSig.verificationTimestampSiblings <== verificationTimestampSiblings;
   participantSig.Ax <== Ax;
   participantSig.Ay <== Ay;
   participantSig.S <== S;
   participantSig.R8x <== R8x;
   participantSig.R8y <== R8y;

   component processor = SMTProcessor(nLevels);
   processor.oldRoot <== oldRoot;
   processor.oldKey <== oldKey;
   processor.oldValue <== 0;
   processor.isOld0 <== isOld0;
   processor.newKey <== S;
   processor.newValue <== 0;
   processor.fnc[0] <== 1;
   processor.fnc[1] <== 0;

   for(var i = 0; i < nLevels; i++) {
      processor.siblings[i] <== siblings[i];
   }

   newRoot === processor.newRoot;
}

component main  {public [documentId, oldRoot, newRoot]} = ValidDocumentVerifierInsert(5);
