#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# setup_pka.sh -- set up a tyrosine pKa calculation with the TYM force fields.
#
# Builds the two protonation END STATES of a tyrosine -- protonated (TYR) and
# deprotonated (TYM) -- each solvated, neutralised and energy-minimisation-ready
# (grompp-validated). These are the equilibrium systems from which the pmx
# TYR<->TYM (Y2YM) non-equilibrium switches are launched; see ../../pmx/README.md
# for the alchemy + BAR step that turns them into a pKa.
#
# The bundled example is an Ala-Tyr-Ala tripeptide (the central tyrosine titrates;
# a model compound for the reference pKa ~10). Pass your own PDB + residue id to
# set up a protein tyrosine instead.
#
# Dependencies: GROMACS only (no pmx needed for this step).
# Usage:   ./setup_pka.sh [PDB] [RESID] [FORCEFIELD]
# Default: ./setup_pka.sh peptide.pdb 2 amber14sb-q-ecc-mut
# ---------------------------------------------------------------------------
set -euo pipefail

PDB="${1:-peptide.pdb}"
RESID="${2:-2}"
FF="${3:-amber14sb-q-ecc-mut}"
GMX="${GMX:-gmx}"

here="$(cd "$(dirname "$0")" && pwd)"
export GMXLIB="$here/../../forcefields"          # shipped .ff dirs + residuetypes.dat (TYM Protein)
[ -d "$GMXLIB/$FF.ff" ] || { echo "force field $FF.ff not found in $GMXLIB"; exit 1; }
echo "PDB=$PDB  residue=$RESID  force field=$FF   GMXLIB=$GMXLIB"

build () {                                        # build <state-name> <input.pdb>
  local name="$1" inp="$2"
  echo "================ building $name end state ================"
  rm -rf "$name"; mkdir -p "$name"; cd "$name"
  printf 'integrator=steep\nnsteps=0\nnstlist=10\ncutoff-scheme=Verlet\ncoulombtype=PME\nrcoulomb=1.0\nrvdw=1.0\n' > ions.mdp
  $GMX pdb2gmx -f "../$inp" -ff "$FF" -water tip3p -ignh -o conf.pdb -p topol.top
  $GMX editconf -f conf.pdb -o box.gro -c -d 1.2 -bt cubic
  $GMX solvate  -cp box.gro -cs spc216.gro -o solv.gro -p topol.top
  $GMX grompp   -f ions.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 3
  echo SOL | $GMX genion -s ions.tpr -o ions.gro -p topol.top -pname NA -nname CL -neutral
  $GMX grompp   -f ../em.mdp -c ions.gro -p topol.top -o em.tpr -maxwarn 3
  echo "  -> $name/em.tpr ready"
  cd ..
}

# --- protonated end state: TYR as-is ----------------------------------------
build tyr "$PDB"

# --- deprotonated end state: rename the chosen Tyr -> TYM --------------------
# (pdb2gmx -ignh rebuilds hydrogens from TYM.hdb, i.e. without the phenolic H)
awk -v r="$RESID" '($1=="ATOM"||$1=="HETATM") && substr($0,23,4)+0==r && substr($0,18,3)=="TYR"{
    $0=substr($0,1,17) "TYM" substr($0,21)} {print}' "$PDB" > tym_input.pdb
build tym tym_input.pdb

echo "================================================================"
echo " DONE.  Two end-state systems built and grompp-validated:"
echo "   tyr/em.tpr   (protonated, TYR)"
echo "   tym/em.tpr   (deprotonated, TYM; residue $RESID)"
echo
echo " Next: minimise + equilibrate each (gmx mdrun), then run the"
echo "       TYR<->TYM (Y2YM) non-equilibrium switches with pmx and BAR:"
echo "       pKa = 9.6 + ddG/(RT ln10).  See ../../pmx/README.md."
echo
echo " For a protein tyrosine: ./setup_pka.sh your.pdb <resid> <ff>"
echo " With an -ecc force field, scale the neutralising ions to +/-0.75."
