pragma circom 2.0.0;

include "./templates/Participant.circom";
include "../node_modules/circomlib/circuits/eddsaposeidon.circom";

template ValidVerifiedParticipantData() {
   var nLevels = 5;

   signal input root;
   signal input key;
   signal input value;
   signal input siblings[nLevels];

   signal input Ax; // first 32 bytes of public key
   signal input Ay; // second 32 bytes of public key
   signal input S;
   signal input R8x; // first 32 bytes of signature
   signal input R8y; // second 32 bytes of signature

   component participantPart = ParticipantPart(nLevels);
   participantPart.root <== root;
   participantPart.key <== key;
   participantPart.value <== value;
   for(var i = 0; i < nLevels; i++) {
      participantPart.siblings[i] <== siblings[i];
   }

   component sig = EdDSAPoseidonVerifier();
   sig.enabled <== 1;
   sig.Ax <== Ax;
   sig.Ay <== Ay;
   sig.S <== S;
   sig.R8x <== R8x;
   sig.R8y <== R8y;
   sig.M <== root;
}

component main  {public [key, value, S, R8x, R8y]} = ValidVerifiedParticipantData();
