# Compact verification evidence

The selected suite has **14 PASS, 0 FAIL, 0 INCONCLUSIVE**. These are recorded
native results from 19 October 2026, not results of a rerun during repository cleanup.

- [results.tsv](results.tsv): selected outcomes, total wall times, formula hashes
  and paths to the corresponding original native records and solver logs.
- [inputs.sha256](inputs.sha256): the checked model, fourteen formulas and English
  requirements. From the repository root, run `shasum -a 256 -c verification/inputs.sha256`.
- [original/](original/): full-batch commands, stage timings, original outcomes,
  graph-generation/count logs and unedited solver logs. Original R12 was interrupted
  without an answer and is INCONCLUSIVE; its original formula is original/R12.mcf.
- [r12-guarded/](r12-guarded/README.md): the separately successful R12 check used
  in the selected suite. Both attempts use the same three-order model.
- [r12-original-retry/](r12-original-retry/SUMMARY.md): the later 90-minute retry
  timed out while awake. Its inconclusive result does not replace the guarded PASS.
- [r12-diagnostic/](r12-diagnostic/README.md): the separate three-state experiment
  discussed in report section 6.5; it is outside the fourteen-property results table.
- [metadata/](metadata/): recorded toolset, OS/hardware, original Git revision/status,
  installed tool help and original input/graph hashes.

## What is and is not stored

Native solver logs and shared graph-generation/count logs are copied verbatim.
Full stage timing and exit-code records are retained. Selected-result path fields
are adjusted to the portable evidence layout; Boolean answers, hashes and runtimes
are unchanged. Original raw records retain their historical filenames and working
directories, which describe the verifying machine rather than prerequisites for
a teammate's checkout. Large LPS/LTS/PBES intermediates, compiled rewriters, verbose
rewriting logs and duplicate source snapshots are deliberately not versioned.
They remain available locally and can be regenerated with the native tools.

The initial graph had 5,915,640 states and 17,854,674 transitions. Strong bisimulation
reduced it to 2,466,516 states and 7,395,390 transitions in a shared setup span of
89.439 seconds. No action hiding or weaker reduction was used. The four per-property
commands are lts2pbes, one-point pbesrewr, pbesparelm and pbessolve with jittyc and
strategy 0. Whole formulas were checked sequentially, not as separate conjuncts.

## Reproduce

Follow [the native instructions](../properties/NATIVE_VERIFICATION.md) from a new
folder in your clone. Use the supplied mCRL2 202607.0 toolset for comparison with
these timings. A quiet stage does not imply failure. A completed native true/false
is PASS/FAIL; tool errors, resource failures and interruption are INCONCLUSIVE.
Do not overwrite this evidence with a new run.

Alternatively, create a fresh isolated input directory and use the shell runner:

```sh
# From the repository root; choose a name that does not already exist.
mkdir verification-local-new
mkdir verification-local-new/properties verification-local-new/run
cp restaurant-conveyor-delivery-system_spec.mcrl2 verification-local-new/
cp properties/R{1..14}.mcf properties/requirements.json verification-local-new/properties/
# Put mCRL2 on PATH first. On macOS, prevent idle sleep for this command:
caffeinate -i bash scripts/verify-report-native.sh "$PWD/verification-local-new"
```

The shell script only sequences and times native commands; it computes no proofs.
The retained original runner in original/ documents the historical execution.
The current runner adds an overwrite check for new runs. Physical timing, kitchen
tag correctness, arbitrary restaurant sizes and guaranteed human participation
are outside this bounded verification.
