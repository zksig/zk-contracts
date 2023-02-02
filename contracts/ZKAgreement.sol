// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./types/ZKAgreementTypes.sol";
import "./verifiers/ValidAgreementId.sol";
import "./verifiers/ValidAgreementSignatureInsert.sol";

contract ZKAgreement is ERC2771Context {
  event CreateAgreement(
    address indexed from,
    uint256 agreementId,
    ZKAgreementTypes.ZKProof proof
  );
  event SignAgreement(
    uint256 indexed agreementId,
    uint256 oldRoot,
    uint256 newRoot,
    ZKAgreementTypes.ZKProof proof
  );

  mapping(uint256 => ZKAgreementTypes.Agreement) agreements;

  constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) {}

  function createAgreement(
    ZKAgreementTypes.CreateAgreementParams memory params
  ) public {
    ZKAgreementTypes.Agreement storage a = agreements[params.agreementId];
    require(a.validAgreementIdProof.a[0] == 0, "Agreement exists");

    // verify agreement id
    bool valid = ValidAgreementId.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.agreementId]
    );
    require(valid, "Invalid agreement id");

    // update contract state
    a.validAgreementIdProof = params.proof;

    // emit events
    emit CreateAgreement(_msgSender(), params.agreementId, params.proof);

    // TODO contract hooks
  }

  function signAgreement(ZKAgreementTypes.SignParams memory params) public {
    ZKAgreementTypes.Agreement storage a = agreements[params.agreementId];

    // verify signature insert
    bool valid = ValidAgreementSignatureInsert.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.agreementId, a.signaturesRoot, params.root]
    );
    require(valid, "Invalid signature insert");

    // TODO verify share

    // emit events
    emit SignAgreement(
      params.agreementId,
      a.signaturesRoot,
      params.root,
      params.proof
    );

    // update contract state
    a.signaturesRoot = params.root;
    a.validSignaturesProof = params.proof;

    // TODO contract hooks
  }
}
