#!/bin/bash -e

./scripts/create-witness.sh $1
./scripts/generate-proof.sh $1
npx snarkjs groth16 verify ${1}/${1}_verification_key.json ${1}/public.json ${1}/proof.json
