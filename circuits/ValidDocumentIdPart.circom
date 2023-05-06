pragma circom 2.0.0;

include "./templates/DocumentId.circom";

component main {public [documentId, key, value]} = DocumentIdPart(4);
