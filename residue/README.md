# TYM residue — standalone building blocks

The authoritative definition of the deprotonated-tyrosine residue `TYM`, for
reference and for grafting into other GROMACS ports. These are the same
parameters already installed in the drop-in force fields under
[`../forcefields/`](../forcefields); use those directly for simulations.

| file | contents |
|---|---|
| `tym_gaff.rtp_entry.txt`    | Amber `TYM` residue topology (`.rtp`), net charge −1; Cζ type **`cq`** |
| `tym_gaff_cq.ffnonbonded.itp` | the new `cq` atom type (GAFF-`c` Lennard-Jones) |
| `tym_gaff_cq.ffbonded.itp`  | Cζ (`cq`) bond/angle/dihedral terms retuned to the condensed-phase QM target |
| `tym_charmm.rtp_entry.txt`  | CHARMM `TYM` residue topology; Cζ type **`CG2R6Q`** |
| `tym_cgenff_params.itp`     | CHARMM `CG2R6Q` parameters (from CGenFF `PHEO`) |
| `tym_capped.pdb`            | capped *N*-acetyl-L-tyrosinate-*N*′-methylamide model (phenolic H removed) |
| `refit_abcg2.sh`            | ABCG2 (AM1-BCC2) side-chain charge recipe (needs AmberTools) |

**Key numbers.** Cζ–Oη condensed-phase target 1.324 ± 0.004 Å; Cε–Cζ–Cε
117.2 ± 0.3° (ωB97X-3c in explicit first-shell water); phenolate-oxygen charge
−0.79 e (Amber, ABCG2) / −0.76 e (CHARMM). For ECC, scale the side-chain charges
to 0.75.
