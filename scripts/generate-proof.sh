#!/bin/bash

npx snarkjs plonk prove ${1}/checker.zkey ${1}/witness.wtns ${1}/proof.json ${1}/public.json
