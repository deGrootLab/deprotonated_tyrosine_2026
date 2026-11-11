# TYR ↔ TYM free-energy / p*K*<sub>a</sub> calculations with pmx

The deprotonation free energy of a tyrosine is obtained from a non-equilibrium
alchemical transformation between protonated tyrosine (`TYR`) and the
tyrosinate residue (`TYM`) provided here, run with
[pmx](https://github.com/deGrootLab/pmx) + GROMACS. The p*K*<sub>a</sub> follows
from

```
pKa = pKa° + ΔΔG / (RT ln 10),     pKa°(Tyr) = 9.6
```

## The hybrid

The alchemical edge is the pmx hybrid **`Y2YM`** (Tyr → tyrosinate) and its
reverse **`YM2Y`**. It is *generated* from the `TYR` and `TYM` end states in the
force fields of this repository — it is not a pre-stored mutation, so no extra
mutation library is needed. The forward and reverse directions let you run a
full cycle and check hysteresis.

## Protocol (as used in the paper)

Double-system / single-box setup; forward and reverse switches launched from
equilibrium simulations of the protonated and deprotonated end states.

- **Ensemble:** NPT, stochastic-dynamics integrator at 298 K, C-rescale barostat
  at 1 bar, PME with 1.2 nm real-space / van der Waals cutoffs, bonds to
  hydrogen constrained.
- **Equilibration:** 15 ns per end state; discard the first 5 ns; take 80 frames
  at 125 ps spacing.
- **Switching:** 200 ps per non-equilibrium transition (400 ps with
  hydrogen-mass repartitioning at a 4 fs timestep for large systems), λ
  interpolated under the Gapsys soft-core potential.
- **Estimator:** Bennett acceptance ratio (BAR) on the forward/backward work
  distributions; bootstrap for uncertainties.
- **ECC:** with the `-ecc` force fields, scale the neutralizing counter-ions to
  ±0.75 to match the scaled solute.

## Sketch of the workflow

```bash
# 0. environment: GROMACS + pmx, with these force fields on $GMXLIB
export GMXLIB=/path/to/tym-forcefield/forcefields

# 1. build the TYR↔TYM hybrid topology for your structure (pmx generates Y2YM)
#    then the double-system/single-box inputs for the two legs.
# 2. equilibrate each end state (15 ns NPT), discard 5 ns, extract 80 frames.
# 3. run 80 forward + 80 reverse 200 ps switches per leg.
# 4. BAR on the work values -> ΔΔG -> pKa = 9.6 + ΔΔG/(RT ln10).
```

> The exact pmx/GROMACS command lines depend on your pmx version and system;
> the steps above and the protocol parameters are the authoritative part. See
> the paper's Methods ("Free energy calculations") for the full specification.
