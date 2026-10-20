# R12: controlled three-state diagnostic

The experiment changes only the explicit order-ID guard, checking the original
and guarded whole R12 files against the same tiny graph, with the same native
mCRL2 version, preprocessing and solve options. The main project and report are
unchanged. This is an isolated reproducer, not a substitute verification result
for the restaurant model. Its toy cycle deliberately omits the other requirements.

## Result

| Version | Native result | Time | Evidence |
|---|---|---|---|
| Explicit ID guard | true / PASS | 3.33 s, including compiled rewriter | [solver log](logs/guarded.solve.log) |
| Original, no explicit ID guard | INCONCLUSIVE at diagnostic limit | 20 s allowance | [solver log](logs/original.solve.log) |

The guarded solver generated 28 BES equations and returned true. The original
loaded its compiled rewriter but returned no Boolean before being stopped.
Idle sleep was inhibited for both runs. The graph has three states and three
transitions: load plate(0,Table1), deliver it to Table1, collect it, then repeat.
Both versions are mathematically true of this cycle: IDs other than zero never
trigger a load. Actual loading and collection occur, so the guard does not make
the whole check vacuous.

## What the generated equations show

[Original PBES](run/original.txt) begins with a quantifier of the form
`forall oid1: Nat, tbl1: TableID. Z0'0(oid1,tbl1)`.
[Guarded PBES](run/guarded.txt) inserts
`val(!(oid1 < 3)) || Z0'0(oid1,tbl1)`.
The full [PBES diff](pbes.diff) contains only this change at the three states.
Thus the finite graph alone has not removed the unrestricted Nat quantifier.
The explicit guard provides the bound directly to the verification problem.

This is strong controlled evidence that the quantification explains the runtime
problem. A finite timeout does not prove the original solver never terminates.
It also is not a full profile of the large restaurant PBES.

## Reproduce using the provided mCRL2 tools

Copy tiny.mcrl2, original.mcf and guarded.mcf into a NEW folder and create run/
inside it. Do not rerun into this evidence directory. From the new run/ folder:

```sh
export PATH="/Applications/mCRL2.app/Contents/bin:$PATH"
mcrl22lps --lin-method=regular ../tiny.mcrl2 tiny.lps
lps2lts tiny.lps tiny.lts
ltsinfo tiny.lts

for name in original guarded; do
  lts2pbes --verbose --preprocess-modal-operators --formula=../${name}.mcf tiny.lts ${name}.pbes &&
  pbesrewr --verbose --pbes-rewriter=quantifier-one-point ${name}.pbes ${name}.one.pbes &&
  pbesparelm --verbose ${name}.one.pbes ${name}.optimized.pbes &&
  pbespp ${name}.optimized.pbes ${name}.txt
done

diff -u original.txt guarded.txt

caffeinate -i /usr/bin/time -p pbessolve --verbose --rewriter=jittyc --solve-strategy=0 guarded.optimized.pbes
caffeinate -i /usr/bin/time -p pbessolve --verbose --rewriter=jittyc --solve-strategy=0 original.optimized.pbes
```

The final command has no built-in timeout; Ctrl+C can stop it. In this recorded
experiment, run-with-limit.pl imposed a 20-second limit on each solver invocation
and recorded exit 124 on timeout. It performs process supervision only, not
verification. All true/false answers come from pbessolve.

