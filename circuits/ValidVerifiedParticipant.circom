pragma circom 2.0.0;

include "./templates/VerifiedParticipant.circom";

component main  {public [documentId, S, R8x, R8y]} = VerifiedParticipant();
