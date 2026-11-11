![License](https://img.shields.io/badge/license-TBD-lightgrey)
![Force fields](https://img.shields.io/badge/force%20fields-Amber%20%7C%20CHARMM-1f77b4)
![GROMACS](https://img.shields.io/badge/GROMACS-drop--in-informational)
![pmx](https://img.shields.io/badge/pmx-TYR%E2%86%94TYM%20free%20energy-6f42c1)
![Paper](https://img.shields.io/badge/paper-2026-e8702a)

# TYM — a transferable deprotonated-tyrosine residue

<!-- optional banner: assets/tym_ring.svg (the Fig. 1a atom-typing panel makes a good logo) -->

**`TYM`** is a drop-in **tyrosinate** residue — tyrosine with the phenol
deprotonated to the anionic **quinoid phenolate** — for the major fixed-charge
protein force fields in **Amber** and **CHARMM**. The backbone is kept identical
to canonical tyrosine; every change is confined to the side chain, so `TYM`
transfers across force-field hosts and composes with the rest of your system.
The parameters are validated against condensed-phase QM geometry, AIMD hydration
structure, and experimental tyrosine p*K*<sub>a</sub> data, and ship with the
pmx TYR↔TYM machinery for free-energy / p*K*<sub>a</sub> calculations.

---

## What is TYM?

Stock Amber and CHARMM provide only *neutral* tyrosine, whose aromatic ring
cannot represent the phenolate: on deprotonation the Cζ–Oη bond gains
double-bond character and the ring loses aromaticity (a **quinoid** form).
`TYM` supplies that state:

- **Amber** — the phenolic H is removed and the ring retyped to a quinoid
  phenolate (after the anionic GFP-chromophore valence set), with a dedicated
  Cζ type **`cq`** (a clone of GAFF `c`) so the lengthened Cζ–Oη bond does
  **not** override the stock `c–o` carbonyl parameters.
- **CHARMM** — the ring is taken from the CGenFF phenolate (`PHEO`:
  `CG2R61` / `HGR61` / `OG312`) grafted onto the CHARMM36m tyrosine backbone,
  with the analogous new Cζ type **`CG2R6Q`**.

The new Cζ bond/angle equilibria are retuned to a **condensed-phase** ωB97X-3c
target (solute re-optimized in explicit first-shell water clusters from AIMD):

| observable | target |
|---|---|
| Cζ–Oη bond | **1.324 ± 0.004 Å** |
| Cε–Cζ–Cε ring angle | **117.2 ± 0.3°** |

Side-chain charges come from **ABCG2** on a capped
*N*-acetyl-L-tyrosinate-*N*′-methylamide model (net −1); the phenolate oxygen
carries **−0.79 e** (Amber) / **−0.76 e** (CHARMM).

---

## Repository layout

```
tym-forcefield/
├── forcefields/          GROMACS drop-in force fields (one per host × charge form)
│   ├── amber14sb-q-mut.ff/            amber14sb-q-ecc-mut.ff/
│   ├── amber19sb-q-mut.ff/            amber19sb-q-ecc-mut.ff/
│   ├── amber99sb-star-ildnp-q-mut.ff/ amber99sb-star-ildnp-q-ecc-mut.ff/
│   ├── charmm36m-mut.ff/             charmm36m-ecc-mut.ff/
│   └── residuetypes.dat              (registers TYM as Protein)
├── residue/              standalone TYM building blocks + ABCG2 charge recipe
└── pmx/                  TYR↔TYM free-energy (p-Ka) workflow  — see pmx/README.md
```

Each host is provided in **full-charge** and **ECC** (electronic-continuum-
correction: side chain scaled to 0.75) forms:

| host | full-charge | ECC |
|---|---|---|
| Amber14SB   | `amber14sb-q-mut.ff`              | `amber14sb-q-ecc-mut.ff` |
| Amber19SB   | `amber19sb-q-mut.ff`             | `amber19sb-q-ecc-mut.ff` |
| Amber99SB\*-ILDN(P) | `amber99sb-star-ildnp-q-mut.ff` | `amber99sb-star-ildnp-q-ecc-mut.ff` |
| CHARMM36m   | `charmm36m-mut.ff`               | `charmm36m-ecc-mut.ff` |

> **Transferability.** The `TYM` side chain (atom types, bonded terms, charges)
> is identical across the three Amber hosts; only the backbone Cα type
> (`CX` / `XC` / `CT` in 14SB / 19SB / 99SB\*) and, for Amber19SB, the backbone
> CMAP differ — both inherited from the host.

---

## Usage

### Build a structure (standard MD)

Copy the force field you need next to your project (or into `$GMXLIB`) and run
`pdb2gmx`:

```bash
export GMXLIB=/path/to/tym-forcefield/forcefields   # so pdb2gmx finds the .ff dirs + residuetypes.dat
gmx pdb2gmx -f protein.pdb -ff amber14sb-q-mut -water tip3p
```

In the input structure, name the deprotonated residue **`TYM`** and remove the
phenolic hydrogen **`HH`** (`pdb2gmx` rebuilds the remaining hydrogens).

**`TYM` must be registered as a protein residue.** This repo's
`forcefields/residuetypes.dat` already contains `TYM  Protein`; make sure
`pdb2gmx` uses it (keep it in `$GMXLIB` or the working directory), or add the
line to your own `residuetypes.dat`.

### ECC

The `-ecc` force fields scale the deprotonated side-chain charge to 0.75; when
you use them, scale the neutralizing counter-ions to ±0.75 as well so the box
stays charge-balanced.

### Always verify

```bash
gmx grompp -f em.mdp -c conf.gro -p topol.top -o em.tpr   # confirm an integer system charge
```

### Free-energy / p*K*<sub>a</sub> calculations

The force fields are pmx-compatible. See [`pmx/README.md`](pmx/README.md) for the
TYR↔TYM (`Y2YM` / `YM2Y`) non-equilibrium alchemy workflow.

---

## Performance 🚀

Tested against experimental tyrosine p*K*<sub>a</sub> values — **29 tyrosines
across 7 proteins** (17 assigned, 12 lower-bound):

| model | AUE (p*K* units) |
|---|---|
| Amber14SB-q-ECC | **0.50** |
| CHARMM36m-ECC | 0.69 |
| **Amber + CHARMM consensus (ECC)** | **0.44** |

The consensus reproduces every measured tyrosine within ~1 p*K* unit. Two
orthogonal checks: the deprotonated state preserves the catalytic
Tyr57···Tyr16 hydrogen bond in **ketosteroid isomerase**, and the residue with a
2<sup>n</sup>-microstate coupling model gives a ground-state protonation
landscape for the **ribonucleotide reductase** radical-transfer pathway (no
radical-specific parameters).

### Validation

Every force field here builds a `TYM`-containing topology and passes
`gmx grompp` (GROMACS 2026.2) with an integer system charge
(−1.000 full-charge, −0.750 ECC); the ff19SB residue-specific CMAP for `TYM`
(inherited from tyrosine) resolves.

---

## Citation

```bibtex
@article{Wilson2026TYM,
  title   = {A Transferable Deprotonated-Tyrosine Residue for p{K}a Prediction},
  author  = {Wilson, Carter J. and de Groot, Bert L.},
  journal = {<journal>},
  year    = {2026},
  doi     = {<DOI>}
}
```

---

## Get in touch

- **Carter J. Wilson** — [`cwilson@mpinat.mpg.de`](mailto:cwilson@mpinat.mpg.de) · ORCID [0000-0002-8992-6269](https://orcid.org/0000-0002-8992-6269)
- **Bert L. de Groot** — ORCID [0000-0003-3570-3534](https://orcid.org/0000-0003-3570-3534)

Computational Biomolecular Dynamics Group, Max Planck Institute for
Multidisciplinary Sciences, Göttingen.

## License
