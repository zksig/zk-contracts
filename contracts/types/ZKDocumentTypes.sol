// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ZKDocumentTypes {
  struct ZKProof {
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
  }

  struct Document {
    uint256 verifiersRoot;
    ZKProof validDocumentIdProof;
    ZKProof validVerifiersProof;
  }

  struct CreateDocumentParams {
    uint256 documentId;
    ZKProof proof;
  }

  struct VerifyDocumentParams {
    uint256 documentId;
    uint256 root;
    ZKProof proof;
  }
}
