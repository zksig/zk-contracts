#!/bin/bash -e

npx snarkjs groth16 setup out/${1}.r1cs phase1/powersOfTau28_hez_final_16.ptau ${1}/circuit_00.zkey
npx snarkjs zkey contribute ${1}/circuit_00.zkey ${1}/circuit_01.zkey --name="1st Contributor Name" --entropy="hoenhuoenuh"
npx snarkjs zkey contribute ${1}/circuit_01.zkey ${1}/circuit_02.zkey --name="2nd Contributor Name" --entropy="abcd1234"
npx snarkjs zkey contribute ${1}/circuit_02.zkey ${1}/circuit_03.zkey --name="3rd Contributor Name" --entropy="1234abcd"
npx snarkjs zkey beacon ${1}/circuit_03.zkey ${1}/${1}.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
npx snarkjs zkey export verificationkey ${1}/${1}.zkey ${1}/${1}_verification_key.json
