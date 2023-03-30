#!/bin/bash -e

mkdir -p $1
mkdir -p out

circom circuits/${1}.circom --r1cs --wasm -o out

# ./scripts/create-witness.sh $1
./scripts/phase2.sh $1
# ./scripts/generate-proof.sh $1
./scripts/create-verifier.sh $1
