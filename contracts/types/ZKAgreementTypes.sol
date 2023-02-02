// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ZKAgreementTypes {
  struct ZKProof {
    uint[2] a;
    uint[2][2] b;
    uint[2] c;
  }

  struct Agreement {
    uint256 signaturesRoot;
    ZKProof validAgreementIdProof;
    ZKProof validSignaturesProof;
  }

  struct CreateAgreementParams {
    uint256 agreementId;
    ZKProof proof;
  }

  struct SignParams {
    uint256 agreementId;
    uint256 root;
    ZKProof proof;
  }
}
