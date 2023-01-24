#!/bin/bash

npx snarkjs plonk verify ${1}/verification_key.json ${1}/public.json ${1}/proof.json
