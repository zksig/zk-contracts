pragma circom 2.0.0;

include "./Participant.circom";
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";

template VerifiedParticipant() {
   var nLevel = 5;

   signal input root;

   signal input documentId;
   signal input documentIdSiblings[nLevel];

   signal input initiator;
   signal input initiatorSiblings[nLevel];

   signal input role;
   signal input roleSiblings[nLevel];

   signal input subrole;
   signal input subroleSiblings[nLevel];

   signal input name;
   signal input nameSiblings[nLevel];

   signal input uniqueIdentifier;
   signal input uniqueIdentifierSiblings[nLevel];

   signal input verificationIPAddress;
   signal input verificationIPAddressSiblings[nLevel];
   
   signal input verificationMethod;
   signal input verificationMethodSiblings[nLevel];

   signal input verificationTimestamp;
   signal input verificationTimestampSiblings[nLevel];

   signal input Ax; // first 32 bytes of public key
   signal input Ay; // second 32 bytes of public key
   signal input S;
   signal input R8x; // first 32 bytes of signature
   signal input R8y; // second 32 bytes of signature

   component participant = Participant();
   participant.root <== root;
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
   participant.verificationIPAddress <== verificationIPAddress;
   participant.verificationIPAddressSiblings <== verificationIPAddressSiblings;
   participant.verificationMethod <== verificationMethod;
   participant.verificationMethodSiblings <== verificationMethodSiblings;
   participant.verificationTimestamp <== verificationTimestamp;
   participant.verificationTimestampSiblings <== verificationTimestampSiblings;

   component sig = EdDSAPoseidonVerifier();
   sig.enabled <== 1;
   sig.Ax <== Ax;
   sig.Ay <== Ay;
   sig.S <== S;
   sig.R8x <== R8x;
   sig.R8y <== R8y;
   sig.M <== root;
}
