// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./types/ZKDocumentTypes.sol";
import "./verifiers/ValidDocumentId.sol";
import "./verifiers/ValidDocumentParticipantInsert.sol";

contract ZKDocument is ERC2771Context {
  event CreateDocument(
    address indexed from,
    uint256 documentId,
    ZKDocumentTypes.ZKProof proof
  );
  event NewDocumentParticipant(
    uint256 indexed documentId,
    ZKDocumentTypes.DigitalSignature verifiedParticipant,
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

  function addDocumentParticipant(
    ZKDocumentTypes.AddDocumentParticipantParams memory params
  ) public {
    ZKDocumentTypes.Document storage doc = documents[params.documentId];

    // verify signature insert
    bool valid = ValidDocumentParticipantInsert.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.documentId, doc.participantsRoot, params.root]
    );
    require(valid, "Invalid participant insert");

    // emit events
    emit NewDocumentParticipant(
      params.documentId,
      params.verifiedParticipant,
      doc.participantsRoot,
      params.root,
      params.proof
    );

    // update contract state
    doc.participantsRoot = params.root;
    doc.validParticipantsProof = params.proof;

    // TODO contract hooks
  }
}
