// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./types/ZKAgreementTypes.sol";
import "./verifiers/ValidAgreementId.sol";
import "./verifiers/ValidAgreementSignatureInsert.sol";

contract ZKAgreement is ERC2771Context {
  event CreateAgreement(address indexed from, uint256 agreementId, bytes proof);
  event SignAgreement(
    uint256 indexed agreementId,
    uint256 oldRoot,
    uint256 newRoot,
    bytes proof
  );

  mapping(uint256 => ZKAgreementTypes.Agreement) agreements;

  constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) {}

  function createAgreement(
    ZKAgreementTypes.CreateAgreementParams memory params
  ) public {
    // verify agreement id
    uint256[] memory pubSignals = new uint256[](1);
    pubSignals[0] = params.agreementId;
    bool valid = ValidAgreementId.verifyProof(params.proof, pubSignals);
    require(valid, "Invalid agreement id");

    // update contract state
    ZKAgreementTypes.Agreement storage a = agreements[params.agreementId];
    a.validAgreementIdProof = params.proof;

    // emit events
    emit CreateAgreement(_msgSender(), params.agreementId, params.proof);

    // TODO contract hooks
  }

  function signAgreement(ZKAgreementTypes.SignParams memory params) public {
    ZKAgreementTypes.Agreement storage a = agreements[params.agreementId];

    // verify signature insert
    uint256[] memory pubSignals = new uint256[](3);
    pubSignals[0] = params.agreementId;
    pubSignals[1] = a.signaturesRoot;
    pubSignals[2] = params.root;

    bool valid = ValidAgreementSignatureInsert.verifyProof(
      params.proof,
      pubSignals
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
