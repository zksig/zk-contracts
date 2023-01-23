pragma circom 2.0.0;

template AgreementId () {
   signal input title;
   signal input totalSigners;
   signal input pdfCID;
   signal input pdfHash;
   signal input totalPages;
   signal input encryptionKey;
   signal output hash;
      
   component id = Poseidon(6);
   id.inputs[0] <== title;
   id.inputs[1] <== totalSigners;
   id.inputs[2] <== pdfCID;
   id.inputs[3] <== pdfHash;
   id.inputs[4] <== totalPages;
   id.inputs[5] <== encryptionKey;
   
   hash <== id.out;
}

component main = AgreementId();
