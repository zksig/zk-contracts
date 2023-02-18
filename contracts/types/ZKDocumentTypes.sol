// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library ZKDocumentTypes {
  struct ZKProof {
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
  }

  struct CreateDocumentParams {
    uint256 documentId;
    uint256 expectedParticipantCount;
    string encryptedDetailsCID;
    ZKProof proof;
  }

  struct AddDocumentParticipantParams {
    uint256 documentId;
    uint256 verifiedParticipant;
    string encryptedParticipantCID;
    uint256 root;
    uint256 nonce;
    ZKProof proof;
  }
}
