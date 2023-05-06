pragma circom 2.0.0;

include "./templates/DocumentId.circom";

template ProofOfAgreement() {
  var nLevels = 4;

  signal input documentId;
  signal input documentTitle;
  signal input pageHash;
  signal input structuredDataHash;
  signal input documentTitleSiblings[nLevels];
  signal input pageHashSiblings[nLevels];
  signal input structuredDataHashSiblings[nLevels];

  // Check document title
  component validDocumentTitle = DocumentIdPart(nLevels);
  validDocumentTitle.documentId <== documentId;
  validDocumentTitle.key <== 0;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check pdf hash
  component validPageHash = DocumentIdPart(nLevels);
  validPageHash.documentId <== documentId;
  validPageHash.key <== 3;
  validPageHash.value <== pageHash;
  validPageHash.siblings <== pageHashSiblings;

  // Check structured data
  component validStructuredDataHash = DocumentIdPart(nLevels);
  validStructuredDataHash.documentId <== documentId;
  validStructuredDataHash.key <== 5;
  validStructuredDataHash.value <== structuredDataHash;
  validStructuredDataHash.siblings <== structuredDataHashSiblings;
}

component main  {public [
  documentId,
  documentTitle,
  pageHash,
  structuredDataHash
]} = ProofOfAgreement();
