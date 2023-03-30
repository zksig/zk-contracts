pragma circom 2.0.0;

include "./Participant.circom";
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template VerifiedParticipantData() {
   var nLevels = 20;

   signal input participantsRoot;
   signal input participantSiblings[20];

   signal input participantId;
   signal input key;
   signal input value;
   signal input siblings[nLevels];

   signal input Ax; // first 32 bytes of public key
   signal input Ay; // second 32 bytes of public key
   signal input S;
   signal input R8x; // first 32 bytes of signature
   signal input R8y; // second 32 bytes of signature

   component participantPart = ParticipantPart(nLevels);
   participantPart.participantId <== participantId;
   participantPart.key <== key;
   participantPart.value <== value;
   participantPart.siblings <== siblings;

   component sig = EdDSAPoseidonVerifier();
   sig.enabled <== 1;
   sig.Ax <== Ax;
   sig.Ay <== Ay;
   sig.S <== S;
   sig.R8x <== R8x;
   sig.R8y <== R8y;
   sig.M <== participantId;

   component smt = SMTVerifier(20);
   smt.enabled <== 1;
   smt.root <== participantsRoot;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== S;
   smt.value <== 0;
   smt.fnc <== 0;
   smt.siblings <== participantSiblings;
}
