pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template AgreementPDF () {
  signal input pages[nLevels];
  signal output root;

      
   component id = Poseidon(6);
   id.inputs[0] <== title;
   id.inputs[1] <== totalSigners;
   id.inputs[2] <== pdfCID;
   id.inputs[3] <== pdfHash;
   id.inputs[4] <== totalPages;
   id.inputs[5] <== encryptionKey;
   
   hash <== id.out;
}
