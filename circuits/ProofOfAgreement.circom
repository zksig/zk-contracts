pragma circom 2.0.0;

include "./templates/DocumentId.circom";

template ProofOfAgreement() {
  var nLevels = 20;

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
  validDocumentTitle.key <== 2139904204642469210661998095148174100843820818705209080323729726810569655635;
  validDocumentTitle.value <== documentTitle;
  validDocumentTitle.siblings <== documentTitleSiblings;

  // Check pdf hash
  component validPageHash = DocumentIdPart(nLevels);
  validPageHash.documentId <== documentId;
  validPageHash.key <== 19286320604300090977313927851360922220698906380410397735753243249770147293983;
  validPageHash.value <== pageHash;
  validPageHash.siblings <== pageHashSiblings;

  // Check structured data
  component validStructuredDataHash = DocumentIdPart(nLevels);
  validStructuredDataHash.documentId <== documentId;
  validStructuredDataHash.key <== 17273568901141502150318856877583604888316741110871333618239496113149740467454;
  validStructuredDataHash.value <== structuredDataHash;
  validStructuredDataHash.siblings <== structuredDataHashSiblings;
}

component main  {public [
  documentId,
  documentTitle,
  pageHash,
  structuredDataHash
]} = ProofOfAgreement();
