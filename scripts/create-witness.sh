#!/bin/bash

node out/${1}_js/generate_witness.js out/${1}_js/${1}.wasm ${1}/input.json ${1}/witness.wtns
