pragma circom 2.0.0;

include "./templates/AgreementId.circom"
include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

// TODO use smt with PDF Pages tree
template PageChecker (pageCount) {
   signal input title;
   signal input totalSigners;
   signal input pdfCID;
   signal input totalPages;
   signal input encryptionKey;
   signal input agreementIdHash;
   signal input pages[pageCount];
   signal input pageHash;  
   
   var found;
   
   component pdf = Poseidon(pageCount);
   component eqs[pageCount];
   component ors[pageCount];
   component notZero = GreaterThan(1);
   notZero.in[1] <== 0;
   
   for(var i = 0; i < pageCount; i++) {
      pdf.inputs[i] <== pages[i];
      eqs[i] = IsEqual();
      eqs[i].in[0] <== pages[i];
      eqs[i].in[1] <== pageHash;

      found += eqs[i].out;
   }

   component agreementId = AgreementId()
   agreementId.title <== title
   agreementId.totalSigners <== totalSigners
   agreementId.pdfCID <== pdfCID
   agreementId.totalPages <== title
   agreementId.encryptionKey <== encryptionKey
   agreementID.pdfHash <== pdf.out

   notZero.in[0] <== found;
   notZero.out === 1;
}

component main  {public [agreementId, pageHash]} = PageChecker(6);
