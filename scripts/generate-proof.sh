#!/bin/bash

npx snarkjs groth16 prove ${1}/${1}.zkey ${1}/witness.wtns ${1}/proof.json ${1}/public.json
