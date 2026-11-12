# Examples

Two small, self-contained worked examples.

| example | what it does | dependencies |
|---|---|---|
| [`coupling_example.py`](coupling_example.py) | Coupled titration of the 1RGG Y51/Y52/Y80 tyrosine triad (paper Fig. 2e): the 2ⁿ-microstate model from intrinsic pKa + pairwise couplings → titration curve, macroscopic midpoints, and one-proton occupancy/delocalisation. Reproduces the Y51/Y80 shared-proton result. | `python3`, `numpy` (`matplotlib` optional for the plot) |
| [`pka_setup/`](pka_setup/) | Set up a tyrosine pKa calculation: builds the protonated (TYR) and deprotonated (TYM) solvated end states, grompp-validated. | GROMACS |

```bash
python3 coupling_example.py          # prints the triad analysis, writes coupling_1rgg.png
cd pka_setup && ./setup_pka.sh       # builds tyr/em.tpr and tym/em.tpr
```

Both run on a laptop in seconds. See [`../pmx/README.md`](../pmx/README.md) for the
full TYR↔TYM free-energy protocol that the pKa setup feeds into.
