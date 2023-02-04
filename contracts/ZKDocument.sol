// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./types/ZKDocumentTypes.sol";
import "./verifiers/ValidDocumentId.sol";
import "./verifiers/ValidDocumentVerifierInsert.sol";

contract ZKDocument is ERC2771Context {
  event CreateDocument(
    address indexed from,
    uint256 documentId,
    ZKDocumentTypes.ZKProof proof
  );
  event VerifyDocument(
    uint256 indexed documentId,
    uint256 oldRoot,
    uint256 newRoot,
    ZKDocumentTypes.ZKProof proof
  );

  mapping(uint256 => ZKDocumentTypes.Document) documents;

  constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) {}

  function createDocument(
    ZKDocumentTypes.CreateDocumentParams memory params
  ) public {
    ZKDocumentTypes.Document storage doc = documents[params.documentId];
    require(doc.validDocumentIdProof.a[0] == 0, "Document exists");

    // verify document id
    bool valid = ValidDocumentId.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.documentId]
    );
    require(valid, "Invalid document id");

    // update contract state
    doc.validDocumentIdProof = params.proof;

    // emit events
    emit CreateDocument(_msgSender(), params.documentId, params.proof);

    // TODO contract hooks
  }

  function verifyDocument(
    ZKDocumentTypes.VerifyDocumentParams memory params
  ) public {
    ZKDocumentTypes.Document storage doc = documents[params.documentId];

    // verify signature insert
    bool valid = ValidDocumentVerifierInsert.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.documentId, doc.verifiersRoot, params.root]
    );
    require(valid, "Invalid verifier insert");

    // TODO verify share

    // emit events
    emit VerifyDocument(
      params.documentId,
      doc.verifiersRoot,
      params.root,
      params.proof
    );

    // update contract state
    doc.verifiersRoot = params.root;
    doc.validVerifiersProof = params.proof;

    // TODO contract hooks
  }
}
