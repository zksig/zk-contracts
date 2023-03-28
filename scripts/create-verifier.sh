#!/bin/bash -e

npx snarkjs zkey export verificationkey ${1}/${1}.zkey ${1}/${1}_verification_key.json
npx snarkjs zkey export solidityverifier ${1}/${1}.zkey contracts/verifiers/${1}.sol
