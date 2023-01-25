// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ZKAgreementTypes {
  struct Agreement {
    uint256 signaturesRoot;
    bytes validAgreementIdProof;
    bytes validSignaturesProof;
  }

  struct CreateAgreementParams {
    uint256 agreementId;
    bytes proof;
  }

  struct SignParams {
    uint256 agreementId;
    uint256 root;
    bytes proof;
  }
}
