#!/bin/bash

npx snarkjs powersoftau prepare phase2 phase1/pot12_0001.ptau phase1/pot12_final.ptau -v
npx snarkjs plonk setup out/${1}.r1cs phase1/pot12_final.ptau ${1}/checker.zkey
npx snarkjs zkey export verificationkey ${1}/checker.zkey ${1}/verification_key.json
