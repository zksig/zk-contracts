pragma circom 2.0.0;

include "./templates/AgreementId.circom";

template ValidAgreementIdPart () {
   signal input root;
   signal input key;
   signal input value;
   signal input siblings[10];

   component verifier = AgreementIdPart();
   verifier.root <== root;
   verifier.key <== key;
   verifier.value <== value;
   for(var i = 0; i < 10; i++) {
      verifier.siblings[i] <== siblings[i];
   }
}

component main  {public [key, value, root]} = ValidAgreementIdPart();
