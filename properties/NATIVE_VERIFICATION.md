# Verification using only the mCRL2 toolset

The verification programs below are supplied with mCRL2. No Python runner or
custom verification algorithm is needed. The report can describe these tool
commands, their purpose, and the Boolean answers they produce.

Create a fresh folder directly inside the mCRL2 project directory and run the
commands there. Choose a folder name that does not already exist. On this Mac:

```sh
# Start at the root of your clone.
export PATH="/Applications/mCRL2.app/Contents/bin:$PATH"
mkdir verification-clean-NEW
cd verification-clean-NEW
```

The commands below assume you remain in that folder. `../` points to the project
directory, so the source model and property files stay there while all generated
files stay in your new verification folder. Run each command only after the previous one
finishes successfully. No previous graph or generated files are needed.

## Generate the state graph once

```sh
mcrl22lps --lin-method=regular ../restaurant-conveyor-delivery-system_spec.mcrl2 model.lps
lpsconstelm model.lps model.const.lps
lpssumelm model.const.lps model.ready.lps
lps2lts --cached --rewriter=jittyc --verbose model.ready.lps complete.lts
ltsconvert --equivalence=bisim complete.lts reduced.lts
```

The first three commands linearise and simplify the model. `lps2lts` explores
the complete state space. Allow it to finish: do not apply a state limit or
use a partial exploration as a complete proof. Its `--cached` option caches
enumerations during this exploration; it does not import an earlier state graph.
`ltsconvert` then merges states using strong bisimulation, preserving modal
mu-calculus properties. These commands retain all action labels; no action-hiding
rules need to be explained for this route.

Exploration is a shared cost paid once for an unchanged model, not once per
property. If the model changes, regenerate its graph.

## Check R1

```sh
lts2pbes --verbose --preprocess-modal-operators --formula=../properties/R1.mcf reduced.lts R1.pbes
pbesrewr --verbose --pbes-rewriter=quantifier-one-point R1.pbes R1.one.pbes
pbesparelm --verbose R1.one.pbes R1.optimized.pbes
pbessolve --verbose --rewriter=jittyc --solve-strategy=0 R1.optimized.pbes
```

`lts2pbes` combines the property and graph into a parameterised Boolean equation
system. The next two tools simplify it. `pbessolve` computes its answer. A complete
`true` is a proof for this bounded model; `false` means the formula is violated.
An interrupted run or tool error is inconclusive.

When several commands are pasted together, the terminal can display all of them
while only the first is running. The last visible command is not necessarily the
active one. The verbose flags provide stage information, although long phases
can still be quiet. The expected output files appear in order: `R1.pbes`,
`R1.one.pbes`, then `R1.optimized.pbes`, followed by the solver's Boolean answer.
Large PBES files can make each stage take minutes. If an existing run is using
CPU and advancing through these stages, let it continue rather than restarting
only to add verbose flags.

For another requirement, change `R1` to its ID in both the property and output
filenames. Reuse `reduced.lts`; no new exploration is needed.

The [fresh report campaign](../verification/README.md)
uses this whole-formula route with a new graph and solver strategy 0. Its
[stage records](../verification/original/stages.tsv) and
[selected property results](../verification/results.tsv) provide
actual timings as stages finish. Earlier projected-clause timings are not used.
R12's original attempt was interrupted at the user's request without an answer;
the selected suite uses a separately recorded revision with the existing
three-order bound made explicit. The original attempt remains INCONCLUSIVE.
Measure graph generation separately from property checking; GUI Verify can use
a different pipeline and its runtimes must be measured independently.

## Check all fourteen properties in order

After graph generation has completed, run this from your new verification folder, where
`reduced.lts` is located. Wait for any earlier verification run to finish first.
The block uses the same native tools, one property at a time, and puts new outputs
and logs in `batch-results`. Choose a different name throughout the block if that
folder already exists; it will not overwrite a previous batch.

```sh
(
  set -o pipefail
  trap 'exit 130' INT TERM
  mkdir batch-results || exit 1

  for requirement in R{1..14}; do
    printf '\nChecking %s\n' "$requirement"

    if {
      lts2pbes --verbose --preprocess-modal-operators \
        --formula="../properties/${requirement}.mcf" \
        reduced.lts "batch-results/${requirement}.pbes" &&
      pbesrewr --verbose --pbes-rewriter=quantifier-one-point \
        "batch-results/${requirement}.pbes" \
        "batch-results/${requirement}.one.pbes" &&
      pbesparelm --verbose \
        "batch-results/${requirement}.one.pbes" \
        "batch-results/${requirement}.optimized.pbes" &&
      pbessolve --verbose --rewriter=jittyc --solve-strategy=0 \
        "batch-results/${requirement}.optimized.pbes"
    } 2>&1 | tee "batch-results/${requirement}.log"; then
      printf '%s finished; see its true/false answer above.\n' "$requirement"
    else
      printf '%s: INCONCLUSIVE (tool error; see log).\n' "$requirement"
    fi
  done
)
```

Each solver prints `true` or `false`, also saved in that property's log. Both
answers allow the loop to continue. A tool error skips the remaining stages of
that property, reports INCONCLUSIVE, and continues with the next property. Ctrl-C
stops the batch. Intermediate PBES files are retained and can be large.

If R1 has already completed and you only want the remaining properties, change
`R{1..14}` to `R{2..14}`. No new state-graph generation is needed. This convenience block writes its outputs under `batch-results`; the report
campaign instead uses the exact per-property filenames in its `run/` directory
and adds stage timing and exit-code records. Both use the same native commands.

## If the assignment requires GUI verification

Use the provided IDE's normal property verification. For R1, each of the three
closed `CHECK` blocks in [R1.mcf](R1.mcf) can be entered as a separate property,
for example R1a, R1b and R1c. R1 is their conjunction, so **all three must be true**.
The comments delimiting CHECK blocks do not tell the GUI to split the work.

This decomposition preserves the requirement, but its GUI runtime is unmeasured.
Inspect the IDE console to see which native tool is active. The project already
enables compiled rewriting (`jittyc`). Three minutes does not establish that a
check is stuck or false. Report the actual GUI runtimes if that is the required
workflow; do not substitute the cached-run timings.

The native command-line route above is part of mCRL2, but whether a course insists
on GUI screenshots or a particular workflow is determined by its assignment.

Official references: [mCRL2 IDE](https://www.mcrl2.org/web/user_manual/tools/release/mcrl2ide.html),
[ltsconvert](https://www.mcrl2.org/web/user_manual/tools/release/ltsconvert.html),
[lts2pbes](https://www.mcrl2.org/web/user_manual/tools/release/lts2pbes.html).
