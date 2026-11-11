#!/usr/bin/env bash
# Reassign the TYM sidechain charges with ABCG2 (AM1-BCC2) using AmberTools.
# Run on a machine that has AmberTools (antechamber/sqm). The sandbox used to
# build this package is linux-aarch64, for which conda-forge has no AmberTools
# build, so charges were NOT computed here.
#
# Input  : tym_capped.pdb  = ACE-(deprotonated Tyr)-NME, all H present, NO phenol H.
# Output : abcg2.mol2 with per-atom AM1-BCC2 charges (net -1).
set -euo pipefail
antechamber -i tym_capped.pdb -fi pdb -o abcg2.mol2 -fo mol2 \
            -c abcg2 -nc -1 -at gaff2 -rn TYM -pf y
echo "ABCG2 charges in abcg2.mol2 (column 9). Map them onto the rtp atoms,"
echo "keeping the chromophore GAFF atom TYPES from TYM.rtp. To keep the residue"
echo "an integer -1 inside the protein, hold the backbone (N,H,CA,HA,C,O) at the"
echo "standard amber14sb Tyr values and let antechamber's -nc -1 distribute the"
echo "rest, or re-run a 2-stage RESP with the backbone restrained."
