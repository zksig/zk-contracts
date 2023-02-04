// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ZKDocumentTypes {
  struct ZKProof {
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
  }

  struct DigitalSignature {
    uint256 R8x;
    uint256 R8y;
    uint256 S;
  }

  struct Document {
    uint256 participantsRoot;
    ZKProof validDocumentIdProof;
    ZKProof validParticipantsProof;
  }

  struct CreateDocumentParams {
    uint256 documentId;
    ZKProof proof;
  }

  struct AddDocumentParticipantParams {
    uint256 documentId;
    DigitalSignature verifiedParticipant;
    uint256 root;
    ZKProof proof;
  }
}
