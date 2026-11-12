# Example: set up a tyrosine pKa calculation

`setup_pka.sh` builds the two protonation **end states** of a tyrosine — protonated
(`TYR`) and deprotonated (`TYM`) — each solvated, neutralised, and
energy-minimisation-ready (validated with `gmx grompp`). These are the equilibrium
systems the pmx **TYR↔TYM (`Y2YM`)** non-equilibrium switches are launched from; the
alchemy + BAR step that turns them into a pKa is in [`../../pmx/README.md`](../../pmx/README.md).

**Dependencies:** GROMACS only (no pmx needed for this step).

## Run

```bash
./setup_pka.sh                       # bundled Ala-Tyr-Ala, residue 2, amber14sb-q-ecc-mut
./setup_pka.sh your.pdb 57 charmm36m-ecc-mut   # a protein tyrosine, your choice of force field
```

Produces `tyr/em.tpr` and `tym/em.tpr`.

## What it does

1. `pdb2gmx` the structure (`-ignh`, so the deprotonated state simply omits the
   phenolic H), then box / solvate / neutralise / `grompp`.
2. For the deprotonated state it renames the chosen `TYR` → `TYM`; everything else
   is identical, so the two systems differ only by that residue's protonation.

The bundled example is an **Ala-Tyr-Ala** tripeptide — a model compound for the
reference tyrosine pKa (~10). (A lone free tyrosine will not build in these Amber
ports as a standalone residue, hence the Ala caps.)

## Files

| file | purpose |
|---|---|
| `setup_pka.sh` | the setup script |
| `peptide.pdb`  | Ala-Tyr-Ala starting structure |
| `em.mdp`       | energy-minimisation parameters |

## Notes

- `TYM` must be registered as a protein residue — handled by
  `../../forcefields/residuetypes.dat`, which the script puts on `$GMXLIB`.
- The script passes `-maxwarn 3` to `grompp` to allow benign warnings: the force
  fields define a couple of GAFF atom types (`c`, `o`) that also appear in the base
  set (grompp uses the last definition), and ECC uses charge-scaled ions.
- With an `-ecc` force field the neutralising ions are the force field's own
  ±0.75 ions, so `genion -neutral` brings the box to net-zero charge.
