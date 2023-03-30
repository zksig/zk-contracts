pragma circom 2.0.0;

include "./templates/Participant.circom";

component main {public [participantId]} = Participant();
