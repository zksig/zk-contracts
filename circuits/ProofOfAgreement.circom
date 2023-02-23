pragma circom 2.0.0;

include "./templates/VerifiedParticipantData.circom";
include "./templates/DocumentId.circom";

template ProofOfAgreement() {
  var nLevels = 5;

  signal input documentId;
  signal input documentTitle;
  signal input pdfHash;
  signal input structuredData;
  signal input documentTitleSiblings[nLevels];
  signal input pdfHashSiblings[nLevels];
  signal input structuredDataSiblings[nLevels];

  // Check document title
  component validDocumentTitle = DocumentIdPart(nLevels);
  validDocumentTitle.root <== documentId;
  validDocumentTitle.key <== 0;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check pdf hash
  component validPDFHash = ParticipantPart(nLevels);
  validPDFHash.root <== documentId;
  validPDFHash.key <== 5;
  validPDFHash.value <== pdfHash;
  validPDFHash.siblings <== pdfHashSiblings;

  // Check structured data
  component validStructuredData = ParticipantPart(nLevels);
  validStructuredData.root <== documentId;
  validStructuredData.key <== 2;
  validStructuredData.value <== structuredData;
  validStructuredData.siblings <== structuredDataSiblings;
}

component main  {public [
  documentId,
  documentTitle,
  pdfHash,
  structuredData
]} = ProofOfAgreement();
