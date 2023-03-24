pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/smt/smtverifier.circom";

template DocumentIdPart(nLevels) {
   signal input root;
   signal input key;
   signal input value;
   signal input siblings[nLevels];

   component smt = SMTVerifier(nLevels);
   smt.enabled <== 1;
   smt.root <== root;
   smt.oldKey <== 0;
   smt.oldValue <== 0;
   smt.isOld0 <== 0;
   smt.key <== key;
   smt.value <== value;
   smt.fnc <== 0;
   for(var i = 0; i < nLevels; i++) {
      smt.siblings[i] <== siblings[i];
   }
}

template DocumentId () {
   var nLevels = 20;

   signal input id;

   signal input title;
   signal input titleSiblings[nLevels];

   signal input type;
   signal input typeSiblings[nLevels];

   signal input pdfCID;
   signal input pdfCIDSiblings[nLevels];

   signal input encryptedPDFCID;
   signal input encryptedPDFCIDSiblings[nLevels];

   signal input pageHash;
   signal input pageHashSiblings[nLevels];

   signal input fieldHash;
   signal input fieldHashSiblings[nLevels];

   signal input structuredDataHash;
   signal input structuredDataHashSiblings[nLevels];

   signal input totalPages;
   signal input totalPagesSiblings[nLevels];

   signal input encryptionKey;
   signal input encryptionKeySiblings[nLevels];

   component titleVerifier = DocumentIdPart(nLevels);
   titleVerifier.root <== id;
   titleVerifier.key <== 2139904204642469210661998095148174100843820818705209080323729726810569655635;
   titleVerifier.value <== title;
   titleVerifier.siblings <== titleSiblings;

   component typeVerifier = DocumentIdPart(nLevels);
   typeVerifier.root <== id;
   typeVerifier.key <== 3959633539973019126498781258361104579367385070006155617600996441045084049154;
   typeVerifier.value <== type;
   typeVerifier.siblings <== typeSiblings;

   component pdfCIDVerifier = DocumentIdPart(nLevels);
   pdfCIDVerifier.root <== id;
   pdfCIDVerifier.key <== 5405063920681412616650502938557453135706262473582367235597357920932717244724;
   pdfCIDVerifier.value <== pdfCID;
   pdfCIDVerifier.siblings <== pdfCIDSiblings;

   component encryptedPDFCIDVerifier = DocumentIdPart(nLevels);
   encryptedPDFCIDVerifier.root <== id;
   encryptedPDFCIDVerifier.key <== 768989198230154210526670777771816572434878781889809242291049576497746439882;
   encryptedPDFCIDVerifier.value <== encryptedPDFCID;
   encryptedPDFCIDVerifier.siblings <== encryptedPDFCIDSiblings;

   component pageHashVerifier = DocumentIdPart(nLevels);
   pageHashVerifier.root <== id;
   pageHashVerifier.key <== 19286320604300090977313927851360922220698906380410397735753243249770147293983;
   pageHashVerifier.value <== pageHash;
   pageHashVerifier.siblings <== pageHashSiblings;

   component fieldHashVerifier = DocumentIdPart(nLevels);
   fieldHashVerifier.root <== id;
   fieldHashVerifier.key <== 12386702604060260896749083610313082265367023767283897698799640581128255585080;
   fieldHashVerifier.value <== fieldHash;
   fieldHashVerifier.siblings <== fieldHashSiblings;

   component totalPagesVerifier = DocumentIdPart(nLevels);
   totalPagesVerifier.root <== id;
   totalPagesVerifier.key <== 11443823930004980164024780974930552062331959489578084721092038418514135822929;
   totalPagesVerifier.value <== totalPages;
   totalPagesVerifier.siblings <== totalPagesSiblings;

   component structuredDataHashVerifier = DocumentIdPart(nLevels);
   structuredDataHashVerifier.root <== id;
   structuredDataHashVerifier.key <== 17273568901141502150318856877583604888316741110871333618239496113149740467454;
   structuredDataHashVerifier.value <== structuredDataHash;
   structuredDataHashVerifier.siblings <== structuredDataHashSiblings;

   component encryptionKeyVerifier = DocumentIdPart(nLevels);
   encryptionKeyVerifier.root <== id;
   encryptionKeyVerifier.key <== 16082508876301636356587620761196943034312226372471142891421981429650484672417;
   encryptionKeyVerifier.value <== encryptionKey;
   encryptionKeyVerifier.siblings <== encryptionKeySiblings;
}

