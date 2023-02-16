pragma circom 2.0.0;

include "./templates/VerifiedParticipantData.circom";

component main  {public [participantsRoot, key, value, S]} = VerifiedParticipantData();
