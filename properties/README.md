# Current R1-R14 requirements and properties

Only R1-R14 are registered in the mCRL2 project. The English requirements in
[requirements.json](requirements.json) match the [report](../report/secure_restaurant_conveyor.tex).
Each .mcf file contains the requirement, its interpretation and complete formula.

- [CATALOG.md](CATALOG.md): requirement mapping, outcomes, runtimes and solver logs.
- [SEMANTICS.md](SEMANTICS.md): formula patterns, assumptions and local monitors.
- [NATIVE_VERIFICATION.md](NATIVE_VERIFICATION.md): reproducible native tool commands.
- [Verification evidence](../verification/README.md): input hashes and measured results.

All fourteen selected properties passed for six positions, two tables and three
total accepted orders. R11-R13 express capability, not guaranteed eventual human
participation or delivery on every execution. R7 includes universal stop progress;
R14 checks deadlock freedom. Correct kitchen tagging and atomic transfers are assumed.
R13 additionally checks recovery independent of collection.

R12 uses an explicit order-ID guard matching the model's existing three-order
bound. It does not reduce the model's capacity. The original attempts without
that guard are retained separately as INCONCLUSIVE. The tiny
[R12 diagnostic](../verification/r12-diagnostic/README.md) explains the difference.

The current report reads these files directly. If the model, requirements or
formulas change, rerun verification and update the results, hashes and report
together. Old S/F files and experimental drafts are not part of the current suite.
