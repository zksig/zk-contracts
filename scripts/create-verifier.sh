#!/bin/bash -e

circom circuits/${1}.circom --r1cs --wasm --sym --c -o out

npx snarkjs powersoftau prepare phase2 phase1/pot12_0001.ptau phase1/pot12_final.ptau -v
npx snarkjs groth16 setup out/${1}.r1cs phase1/pot12_final.ptau ${1}/checker.zkey
npx snarkjs zkey export verificationkey ${1}/checker.zkey ${1}/verification_key.json
npx snarkjs zkey export solidityverifier ${1}/checker.zkey contracts/verifiers/${1}.sol
