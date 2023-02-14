pragma circom 2.0.0;

include "./templates/DocumentId.circom";

component main {public [root, key, value]} = DocumentIdPart(5);
