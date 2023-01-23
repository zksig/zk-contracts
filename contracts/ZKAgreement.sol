// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ZKAgreement {
  struct Agreement {
    bytes signaturesRoot;
    bytes validAgreementIdProof;
    bytes validSignaturesProof;
  }

  struct CreateAgreementParams {
    bytes agreementId;
    bytes proof;
  }

  struct SignParams {
    bytes agreementId;
    bytes root;
    bytes proof;
  }

  mapping(bytes => Agreement) agreements;

  function createAgreement(CreateAgreementParams memory params) public {
    // verify proof

    Agreement storage a = agreements[params.agreementId];
    a.validAgreementIdProof = params.proof;

    // emits and hooks
  }

  function signAgreement(SignParams memory params) public {
    // verify proof
    // verify shared

    Agreement storage a = agreements[params.agreementId];
    a.signaturesRoot = params.root;
    a.validSignaturesProof = params.proof;

    // emits and hooks
  }
}
