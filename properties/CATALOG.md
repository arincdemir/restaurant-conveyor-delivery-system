# Current R1–R14 property catalog

Only R1–R14 are registered. The English requirements and model remain unchanged. R12 uses the user-approved finite order-ID guard; its original attempt and the separate revision are both retained.

[Fresh native evidence](../verification/README.md) · [Selected results](../verification/results.tsv) · [Original attempts](../verification/original/results.tsv) · [R12 revision](../verification/r12-guarded/README.md)

**Fresh outcome: 14 PASS, 0 FAIL, 0 INCONCLUSIVE.** Every row below belongs to this campaign; no historical answer or timing is substituted.

The graph was generated from the frozen model and strongly bisimulation reduced, retaining all action labels. Each complete formula is checked sequentially through the requested native four-command pipeline, with no automatic timeout, conjunct splitting, action hiding or alternative backend. R12 alone has a separately recorded, user-approved revision. Total property times exclude the shared five-command graph setup (89.439 seconds).

| Requirement | Formula | Outcome | Total seconds | Evidence |
| --- | --- | --- | ---: | --- |
| R1: A box's two gates must never be open together. | [R1.mcf](R1.mcf) | PASS | 515.052 | [native log](../verification/original/logs/R1.pbessolve.log) |
| R2: A plate may be delivered only to the table named on its tag. | [R2.mcf](R2.mcf) | PASS | 79.130 | [native log](../verification/original/logs/R2.pbessolve.log) |
| R3: Each order may be loaded at most once and delivered at most once. | [R3.mcf](R3.mcf) | PASS | 479.073 | [native log](../verification/original/logs/R3.pbessolve.log) |
| R4: The kitchen may load only into an empty loading position while the belt is stopped. | [R4.mcf](R4.mcf) | PASS | 342.973 | [native log](../verification/original/logs/R4.pbessolve.log) |
| R5: A plate may enter only an empty delivery box. | [R5.mcf](R5.mcf) | PASS | 183.980 | [native log](../verification/original/logs/R5.pbessolve.log) |
| R6: A pusher may start only with the correct plate aligned, the belt stopped, the inner gate open, and the outer gate closed. It must retract before the inner gate closes. | [R6.mcf](R6.mcf) | PASS | 1426.620 | [native log](../verification/original/logs/R6.pbessolve.log) |
| R7: The belt may start or advance only after every station has finished or skipped its work for the current stop, all inner gates are closed, and all pushers are retracted. The belt must eventually advance from each normal servicing stop, unless an emergency interrupts. | [R7.mcf](R7.mcf) | PASS | 1191.969 | [native log](../verification/original/logs/R7.pbessolve.log) |
| R8: Customers may collect only from an occupied box with its outer gate open and its inner gate closed. | [R8.mcf](R8.mcf) | PASS | 1144.686 | [native log](../verification/original/logs/R8.pbessolve.log) |
| R9: From an emergency request until reset, belt start or advance, loading, pushing, and inner-gate opening are blocked. | [R9.mcf](R9.mcf) | PASS | 157.185 | [native log](../verification/original/logs/R9.pbessolve.log) |
| R10: Reset requires all controllers to have received the current emergency notification and the operator to have cleared that emergency. | [R10.mcf](R10.mcf) | PASS | 99.893 | [native log](../verification/original/logs/R10.pbessolve.log) |
| R11: Every accepted order can be prepared and loaded during normal operation, without requiring an emergency. | [R11.mcf](R11.mcf) | PASS | 253.523 | [native log](../verification/original/logs/R11.pbessolve.log) |
| R12: Every loaded plate can reach its tagged box without requiring an emergency. After delivery, collection must remain possible. | [R12.mcf](R12.mcf) | PASS | 492.164 | [native log](../verification/r12-guarded/logs/R12.pbessolve.log) |
| R13: Every emergency permits an approved reset. After reset, the belt can advance again without another emergency. | [R13.mcf](R13.mcf) | PASS | 321.313 | [native log](../verification/original/logs/R13.pbessolve.log) |
| R14: Every reachable state must have a possible action. Waiting for a customer or operator is allowed if they can still act. | [R14.mcf](R14.mcf) | PASS | 66.067 | [native log](../verification/original/logs/R14.pbessolve.log) |

R12’s original attempt without an explicit ID guard is INCONCLUSIVE after a user-approved interruption
at 5596.490 seconds. It remains in the original results.tsv. The reported R12 row
uses the separately recorded guarded revision, not that unfinished attempt. Its
first conjunct adds `val(oid < maxOrders) =>`; loading already requires that guard
in this model. No English requirement or model behaviour was changed.

## Reading the results

Only a completed native `true` gives PASS and `false` gives FAIL. Tool errors,
resource failure, missing final output or interruption give INCONCLUSIVE. The
stage table contains every attempted command's exit code; a failed dependency
prevents later stages for that property. The shell performs no proof algorithm.

R7's three-state monitor requires StationDone from the kitchen and both tables
for the current stop; SendSkip alone does not complete it. Its normal-stop
least fixed point requires advancement or emergency on every continuation.
R11–R13 use capability semantics. R13's unchanged formula also excludes dependence
on collection, which is stronger than its English requirement. The frozen R7
comment describing the pre-run verification status is superseded by this table.

[SEMANTICS.md](SEMANTICS.md) explains the complete formulas;
[NATIVE_VERIFICATION.md](NATIVE_VERIFICATION.md) gives tool-only commands.
The report reads the versioned inputs directly. Their hashes match the checked
revision in ../verification/inputs.sha256. Source requirements are preserved verbatim.

Coverage is six positions, two tables, three total accepted orders, one meal
value and atomic transfers. Kitchen tagging is assumed. Guaranteed delivery,
physical timing and guaranteed human participation are not established.

Superseded S/F properties and experimental drafts are excluded from the current
repository tree; previously committed versions remain in Git history.
