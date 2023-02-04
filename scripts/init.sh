#!/bin/bash

mkdir -p phase1
npx snarkjs powersoftau new bn128 16 phase1/pot12_0000.ptau -v
npx snarkjs powersoftau contribute phase1/pot12_0000.ptau phase1/pot12_0001.ptau --name="First contribution" --entropy="nhuoentuh"
