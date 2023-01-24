pragma circom 2.0.0;

include "./templates/ValidAgreementSignature.circom";

component main  {public [agreementId, S, R8x, R8y]} = ValidAgreementSignature();
