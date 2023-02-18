// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@tableland/evm/contracts/utils/TablelandDeployments.sol";
import "@tableland/evm/contracts/utils/SQLHelpers.sol";
import "./types/ZKDocumentTypes.sol";
import "./verifiers/ValidDocumentId.sol";
import "./verifiers/ValidDocumentParticipantInsert.sol";

contract ZKDocument is ERC2771Context, Ownable, ERC721Holder {
  event CreateDocument(
    address indexed from,
    uint256 documentId,
    ZKDocumentTypes.ZKProof proof
  );

  event NewDocumentParticipant(
    uint256 indexed documentId,
    uint256 verifiedParticipant,
    uint256 oldRoot,
    uint256 newRoot,
    ZKDocumentTypes.ZKProof proof
  );

  struct Document {
    uint256 participantsRoot;
    bool initialized;
  }

  mapping(uint256 => Document) documents;

  uint256 private _documentsTableId;
  uint256 private _auditLogTableId;

  string private constant _DOCUMENT_TABLE_PREFIX = "zk_documents";
  string private constant _AUDIT_LOG_TABLE_PREFIX = "zk_audit_trail";

  constructor(
    MinimalForwarder forwarder
  ) ERC2771Context(address(forwarder)) Ownable() {}

  function getDocumentsTableId() public view returns (uint256) {
    return _documentsTableId;
  }

  function getAuditLogTableId() public view returns (uint256) {
    return _auditLogTableId;
  }

  function setupTables() public onlyOwner {
    _documentsTableId = TablelandDeployments.get().createTable(
      address(this),
      SQLHelpers.toCreateFromSchema(
        "id text,"
        "status text,"
        "expectedParticipantCount integer,"
        "totalParticipantCount integer,"
        "encryptedDetailsCID text,"
        "zkpA0 text,"
        "zkpA1 text,"
        "zkpB00 text,"
        "zkpB01 text,"
        "zkpB10 text,"
        "zkpB11 text,"
        "zkpC0 text,"
        "zkpC1 text",
        _DOCUMENT_TABLE_PREFIX
      )
    );

    _auditLogTableId = TablelandDeployments.get().createTable(
      address(this),
      SQLHelpers.toCreateFromSchema(
        "id integer primary key,"
        "documentId text,"
        "verifiedParticipant text,"
        "encryptedParticipantCID text,"
        "smtRoot text,"
        "nonce text,"
        "zkpA0 text,"
        "zkpA1 text,"
        "zkpB00 text,"
        "zkpB01 text,"
        "zkpB10 text,"
        "zkpB11 text,"
        "zkpC0 text,"
        "zkpC1 text",
        _AUDIT_LOG_TABLE_PREFIX
      )
    );
  }

  function createDocument(
    ZKDocumentTypes.CreateDocumentParams memory params
  ) public {
    Document storage doc = documents[params.documentId];
    require(!doc.initialized, "Document exists");

    // verify document id
    bool valid = ValidDocumentId.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.documentId]
    );
    require(valid, "Invalid document id");

    // initialize document
    doc.initialized = true;

    // store document data
    // TablelandDeployments.get().runSQL(
    //   address(this),
    //   _documentsTableId,
    //   SQLHelpers.toInsert(
    //     _DOCUMENT_TABLE_PREFIX,
    //     _documentsTableId,
    //     "id,status,expectedParticipantCount,totalParticipontCount,encryptedDetailsCID,zkpA0,zkpA1,zkpB00,zkpB01,zkpB10,zkpB11,zkpC0,zkpC1",
    //     createDocumentInsertQuery(params)
    //   )
    // );

    // emit events
    emit CreateDocument(_msgSender(), params.documentId, params.proof);

    // TODO contract hooks
  }

  function addDocumentParticipant(
    ZKDocumentTypes.AddDocumentParticipantParams memory params
  ) public {
    Document storage doc = documents[params.documentId];
    require(doc.initialized, "Document doesn't exist");

    // verify signature insert
    bool valid = ValidDocumentParticipantInsert.verifyProof(
      params.proof.a,
      params.proof.b,
      params.proof.c,
      [params.documentId, doc.participantsRoot, params.root]
    );
    require(valid, "Invalid participant insert");

    // store participant in audit log
    // TablelandDeployments.get().runSQL(
    //   address(this),
    //   _auditLogTableId,
    //   SQLHelpers.toInsert(
    //     _AUDIT_LOG_TABLE_PREFIX,
    //     _auditLogTableId,
    //     "documentId,verifiedParticipant,encryptedParticipantCID,smtRoot,nonce,zkpA0,zkpA1,zkpB00,zkpB01,zkpB10,zkpB11,zkpC0,zkpC1",
    //     createAuditLogInsertQuery(params)
    //   )
    // );

    // update document participants root
    doc.participantsRoot = params.root;

    // emit events
    emit NewDocumentParticipant(
      params.documentId,
      params.verifiedParticipant,
      doc.participantsRoot,
      params.root,
      params.proof
    );

    // TODO contract hooks
  }

  function _msgSender()
    internal
    view
    override(Context, ERC2771Context)
    returns (address sender)
  {
    sender = ERC2771Context._msgSender();
  }

  function _msgData()
    internal
    view
    override(Context, ERC2771Context)
    returns (bytes calldata)
  {
    return ERC2771Context._msgData();
  }

  function createDocumentInsertQuery(
    ZKDocumentTypes.CreateDocumentParams memory params
  ) internal pure returns (string memory) {
    return
      string.concat(
        SQLHelpers.quote(Strings.toString(params.documentId)),
        ",",
        SQLHelpers.quote("pending"),
        ",",
        Strings.toString(params.expectedParticipantCount),
        ",",
        "0",
        ",",
        SQLHelpers.quote(params.encryptedDetailsCID),
        ",",
        createProofQuery(params.proof)
      );
  }

  function createAuditLogInsertQuery(
    ZKDocumentTypes.AddDocumentParticipantParams memory params
  ) internal pure returns (string memory) {
    return
      string.concat(
        SQLHelpers.quote(Strings.toString(params.documentId)),
        ",",
        SQLHelpers.quote(Strings.toString(params.verifiedParticipant)),
        ",",
        SQLHelpers.quote(params.encryptedParticipantCID),
        ",",
        SQLHelpers.quote(Strings.toString(params.root)),
        ",",
        SQLHelpers.quote(Strings.toString(params.nonce)),
        ",",
        createProofQuery(params.proof)
      );
  }

  function createProofQuery(
    ZKDocumentTypes.ZKProof memory proof
  ) internal pure returns (string memory) {
    return
      string.concat(
        SQLHelpers.quote(Strings.toString(proof.a[0])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.a[1])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.b[0][0])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.b[0][1])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.b[1][0])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.b[1][1])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.c[0])),
        ",",
        SQLHelpers.quote(Strings.toString(proof.c[1]))
      );
  }
}
