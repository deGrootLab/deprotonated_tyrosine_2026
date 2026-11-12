#!/usr/bin/env python3
"""
Coupled-titration example: the Y51/Y52/Y80 tyrosine triad of ribonuclease Sa (PDB 1RGG).

Given each tyrosine's intrinsic pKa (its pKa with all coupling partners protonated)
and the pairwise couplings W_ij, the joint titration of the n sites follows from the
2^n protonation microstates:

    G(x)/2.303RT = sum_i x_i (pKintr_i - pH)  +  sum_{i<j} W_ij x_i x_j

where x_i = 1 marks site i DEPROTONATED. This script enumerates the 8 microstates,
builds the titration, and reports the one-proton occupancy/delocalisation of a pair
(Fig. 2e of the paper). No MD is needed -- the inputs below are the alchemical result.

Inputs: Amber14SB-q-ECC values for 1RGG (TYR<->TYM free energies -> pKa, W_ij).
Run:    python3 coupling_example.py
"""
import itertools
import numpy as np

# --- inputs (Amber14SB-q-ECC, 1RGG) -----------------------------------------
SITES = ["Y51", "Y52", "Y80"]
PKINTR = {"Y51": 12.35, "Y52": 13.76, "Y80": 12.87}        # intrinsic pKa
W = {("Y51", "Y52"): 1.06, ("Y52", "Y80"): 1.09, ("Y51", "Y80"): 0.00}  # pK units
def Wij(i, j):
    return W.get((i, j)) if (i, j) in W else W.get((j, i), 0.0)

# --- 2^n microstate titration ------------------------------------------------
pH = np.linspace(6, 20, 561)
states = list(itertools.product([0, 1], repeat=len(SITES)))  # x=1 -> deprotonated
idx = {s: k for k, s in enumerate(SITES)}

logw = np.zeros((len(states), len(pH)))
for si, st in enumerate(states):
    dep = [s for s, x in zip(SITES, st) if x == 1]
    ex = sum(pH - PKINTR[s] for s in dep)
    for a in range(len(dep)):
        for b in range(a + 1, len(dep)):
            ex -= Wij(dep[a], dep[b])
    logw[si] = ex
P = 10 ** (logw - logw.max(0))
P /= P.sum(0)                                   # microstate probabilities vs pH

ndep = np.array([sum(st) for st in states])
nbound = (len(SITES) - ndep) @ P                # bound protons n(pH) = 3 - <#deprotonated>
frac_prot = {s: P[[k for k, st in enumerate(states) if st[idx[s]] == 0]].sum(0) for s in SITES}

# --- pair occupancy H and delocalisation S (paper Eqs.) ----------------------
def pair_HS(a, b):
    ia, ib = idx[a], idx[b]
    Pab = P[[k for k, st in enumerate(states) if st[ia] == 0 and st[ib] == 1]].sum(0)  # H on a
    Pba = P[[k for k, st in enumerate(states) if st[ia] == 1 and st[ib] == 0]].sum(0)  # H on b
    one = Pab + Pba
    k = int(one.argmax())
    S = 2 * min(Pab[k], Pba[k]) / one[k] if one[k] > 1e-9 else 0.0
    return one[k], S, pH[k]

# --- report ------------------------------------------------------------------
print("1RGG Y51/Y52/Y80 triad  (Amber14SB-q-ECC)")
print("  intrinsic pKa:", {s: PKINTR[s] for s in SITES})
print("  couplings W_ij:", {f"{i}/{j}": w for (i, j), w in W.items()})
# macroscopic midpoints: pH where n(pH) crosses 2.5, 1.5, 0.5
for target in (2.5, 1.5, 0.5):
    j = int(np.argmin(abs(nbound - target)))
    print(f"  macroscopic pKa ~ {pH[j]:4.1f}   (n crosses {target})")
for a, b in [("Y51", "Y80"), ("Y51", "Y52"), ("Y52", "Y80")]:
    H, S, pk = pair_HS(a, b)
    tag = "shared" if S > 0.4 else "localised"
    print(f"  {a}/{b}: one-proton occupancy={H:.2f}, delocalisation S={S:.2f} ({tag}) at pH {pk:.1f}")

# --- optional plot (skipped automatically if matplotlib is absent) -----------
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots(figsize=(5, 3.2))
    for s, c in zip(SITES, ["#2ca02c", "#6784d1", "#f39b7f"]):
        ax.plot(pH, frac_prot[s], color=c, lw=1.6, label=f"{s} protonated")
    ax.set_xlabel("pH"); ax.set_ylabel("fraction protonated"); ax.set_ylim(-0.02, 1.02)
    ax2 = ax.twinx()
    ax2.plot(pH, nbound, "k--", lw=1.8, label="n(pH) bound protons")
    ax2.set_ylabel("bound protons  n(pH)"); ax2.set_ylim(-0.1, 3.1)
    ax.legend(loc="lower left", fontsize=7, frameon=False)
    fig.tight_layout()
    fig.savefig("coupling_1rgg.png", dpi=150)
    print("wrote coupling_1rgg.png")
except Exception as e:
    print(f"(plot skipped: {e})")
