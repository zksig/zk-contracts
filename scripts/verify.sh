#!/bin/bash -e

./scripts/create-witness.sh $1
./scripts/generate-proof.sh $1
npx snarkjs plonk verify ${1}/verification_key.json ${1}/public.json ${1}/proof.json
