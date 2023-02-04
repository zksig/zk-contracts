#!/bin/bash -e

npx snarkjs powersoftau prepare phase2 phase1/pot12_0001.ptau phase1/pot12_final.ptau -v
npx snarkjs groth16 setup out/${1}.r1cs phase1/pot12_final.ptau ${1}/checker_00.zkey
npx snarkjs zkey contribute ${1}/checker_00.zkey ${1}/${1}.zkey --name="1st Contributor Name" --entropy="hoenhuoenuh"
npx snarkjs zkey export verificationkey ${1}/${1}.zkey ${1}/${1}_verification_key.json
