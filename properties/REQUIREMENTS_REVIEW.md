# Requirement wording and coverage

The numbering here follows the original S1–S12 / F1–F9 list in the conversation.
The report currently contains a partially rewritten action-based list with some
items commented out, so its displayed numbering does not consistently match.
The report and model have not been edited by this property change.

Each requirement now has an expressive `.mcf` file and a `_short.mcf` alternative.
The short alternatives retain the same guarantee on the current model. More
comments and descriptive monitor parameters explain the expressive versions;
simple history rules replace monitors where that makes the short version clear.
Shorter source does not necessarily produce a smaller verification problem.

## Clear wording for the existing requirements

| ID | Suggested concise wording | Interpretation or limitation |
| --- | --- | --- |
| S1 | A box's inner and outer gates are never open together. | Keep. Start from the actual inner-open, outer-closed initial state. |
| S2 | A transferred plate goes only to its tagged destination. | Keep. This checks the plate tag, not whether the tag matches the original accepted order. |
| S3 | A plate is transferred only into an empty box. | Keep. Collection makes the box empty; closing a gate does not. |
| S4 | Push only while stopped with the matching plate aligned, inner gate open, and outer gate closed; retract before movement or gate release. | Keep. The formula uses the synchronized live-slot snapshot and invalidates it after advancement/removal. |
| S5 | Advance only with all inner gates closed and all pushers retracted. | Keep, or make this the mechanical part of S9. |
| S6 | Loading never overwrites an occupied belt slot. | Better than only saying “at most one plate”: `PlateSlot` already enforces that representation. The formula tracks all six occupancies through rotation and removal. |
| S7 | Each order is delivered at most once. | Keep. `Plate` already contains one OrderID, so “each plate is associated with one order” is partly a type invariant. This does not prove that preparation/loading happens only once. |
| S8 | Each station sends one completion per completed round; a skipped station sends one skip before its completion. Emergency notification may cancel an unfinished round. | Replace “one completion or skip.” In this model a skip is followed by `StationDone`, so counting both as alternative final replies is inaccurate. Advance still requires all three replies; reset starts a fresh round after cancellation. This safety property does not require fair scheduling. |
| S9 | Advance only after a current servicing round has all three station replies and satisfies S5. | Keep as an integration check. It overlaps S5 and S8 but makes the complete advance condition explicit. |
| S10 | Between StartEmergency and valid reset, no conveyor start, advance, loading, pushing, or inner-gate opening occurs. | Keep. Safe finishing actions such as retraction and gate closure remain allowed. |
| S11 | Emergency release opens an outer gate only after the paired inner gate closes. | Sensible, but already implied by S1. The implemented S11 checks the stronger all-time interlock and is identical to S1. One canonical formula is enough if you want fewer checks. |
| S12 | Resume only after notification, explicit operator clearance, and synchronized safe reset. | Keep this concrete protocol. “An emergency ends only after EndEmergency” alone is almost a naming tautology. |
| F1 | Every accepted order has a path to preparation and loading. | Keep “can”: this is capability, not inevitable service under every execution. Acceptance lacks an ID payload, so the formula tracks the acceptance counter. S6 checks empty-slot loading separately. |
| F2 | A matching plate arriving at an available box can transfer before the belt advances. | Keep. Available means empty with its outer gate closed. The formula allows gate preparation before pushing. |
| F3 | An occupied box skips a matching arriving plate; that plate can remain on the belt through the next advance. | This is the checked one-round interpretation. “Continues circulating” indefinitely requires advancement assumptions; emergency may intentionally prevent advancement. |
| F4 | Both available tables can service their aligned plates independently while stopped. | “Concurrent” is ambiguous. The supplied formula tests the stricter, single simultaneous event interpretation, which fails. See the two readings below. |
| F5 | After transfer, close the inner gate before opening the outer gate. | Keep as a clear sequence check, but classify it as ordering safety. It does not by itself require the outer gate eventually to open. It overlaps S1 when S4 guarantees the inner gate starts open. |
| F6 | After collection, eventually close the outer gate before any new transfer into that box. | The formula checks all maximal executions, including deadlocks. During emergency the gate may remain open until reset. If operator clearance is an external assumption, say so in the requirement. |
| F7 | With continued advancement and eventual collection of blocking plates, every loaded plate is eventually delivered. | Prefer this to “the box becomes available once”: a different plate can take that one opportunity. Both existing interpretations remain available. |
| F8 | Every reachable state has an outgoing transition. | Keep. “Unintended” needs a definition if terminal states are ever introduced. Deadlock freedom alone does not imply useful progress. |
| F9 | After every valid reset, some path reaches conveyor advancement. | Keep. This is possible recovery, not guaranteed movement on every execution. Also check reset reachability to avoid vacuous success. |

Replacing `Occupied(oldPlate)` with `Occupied(newPlate)` still leaves at most
one plate in a slot, but loses the old plate. This is why the operational S6
non-overwrite check is more useful than the representation invariant alone.

## F4: simultaneous actions versus independent service

Independent controllers, overlapping pusher operation, and one joint atomic
transfer are different notions of concurrency. The provided F4 files explicitly
choose the strict joint-event interpretation; the original word “concurrently”
does not uniquely require that interpretation.

The current conveyor receives one transfer and updates its list before receiving
another. The `allow` set permits a single `Push | BoxFilled | PlateTransferred`
multi-action, and excludes a joint multi-action containing both transfers.
Even broadening `allow` would not make the single conveyor process receive both
in one step. Consequently, literal simultaneous F4 conflicts with this chosen
model abstraction. This does not establish a failure of independent service.

A suitable replacement is:

> If both destination boxes are available and both correct plates are aligned,
> there is a path completing both transfers before the next conveyor advance,
> in either order, provided no emergency begins.

“In either order” means both orderings are possible, not merely that one ordering
exists. This expresses independent service in the current interleaving model.
This is another interpretation of “concurrent.” Agree on the intended wording
before treating the strict F4 failure as a model defect. The native witnesses
also start both pushes before either retracts, demonstrating overlapping pusher
operation despite the absence of a joint atomic transfer. A requirement for one
simultaneous transfer event would need a different transfer abstraction.

## F6 and environmental progress

Normal collection has `BoxEmptied . CloseOuterGate`. Emergency collection can
leave the outer gate open until reset, so “immediately close after collection”
would be inaccurate for emergency release.

The F6 files check eventual closure, plus no refill before closure. Remember that
an enabled operator action is a transition in this closed model. Refusing to take
an enabled action while time passes is not itself an execution: time and operator
waiting are not modelled. A passing unconditional liveness check therefore does
not prove that a real operator will eventually clear an emergency.

For a requirement that explicitly separates the human role, use:

> Following collection in normal operation, close the outer gate before reuse.
> During emergency release it may remain open; after valid reset, an empty box
> closes its outer gate and can return to normal service.

## Action-based report wording that needs revision

The report draft still refers to `ScanId`, `CheckEmptyBox`, and `ReportSkip`.
Those are absent from the current model. `CheckPosOne` also has no Boolean result
payload; `LoadingPosition(Empty)` supplies empty-slot information. Matching table
information is carried by the round's `ConveyorPosition` snapshot. A skip is
`SendSkip`, followed by the actual completion `StationDone`.

Replacing at-most-once delivery by unique `AddPlate` calls loses coverage: unique
preparation does not by itself prevent duplicate loading or delivery. Likewise,
requiring only delivery-box skips before advancement omits successful deliveries
and the kitchen's report. Keep requirements in terms of observable events that
actually exist, and state which event represents preparation, transfer, collection,
completion, and reset.

Do not remove S2, S3, or S6 merely because F1/F2 describe a successful delivery
path. A system can have one correct path and still permit wrong deliveries or
overwriting on other paths. Likewise, safety rules do not imply F8 deadlock
freedom or F9 recovery capability.

The action-based S10 draft also asks for `StopConveyor` and `StopLoading` after
the request. The existing S10 formula checks immediate inhibition of unsafe
actions; it does not separately require those two response events. Include them
in an explicit emergency-response/recovery requirement, with progress assumptions
if eventual stopping must hold on every execution.

## Additional requirements worth discussing

These are suggestions, not extra registered property files or model changes.

| Suggested requirement | Why the existing list does not fully cover it |
| --- | --- |
| Load only an accepted, prepared order, with its accepted destination; prepare/load each order at most once. | S2 checks the tag at delivery and S7 checks repeat delivery. Neither alone catches invented food, altered tags, or duplicate loading. |
| Preserve each plate: it is prepared, on exactly one belt slot, in exactly one box, or collected; emergency/reset neither loses nor duplicates it. | “At most once delivered” can pass when a plate disappears. This also directly covers prepared food preserved across cancellation. |
| Round snapshots equal live slots 0, 2, and 4; Advance rotates every slot one position, wrapping 5 to 0. | S4 checks reported alignment and S6 checks occupancy. Explicit snapshot/rotation fidelity would also detect a consistently wrong station mapping. |
| Collect only from an occupied box with its outer gate open and its inner gate closed. | Gate exclusion and safe pushing do not specify the preconditions of customer collection. |
| Permit reset only after all controllers recover safely, and preserve orders, queues, belt contents, and occupied boxes through reset. | S12 verifies notification/operator/reset order, but the physical readiness and data preservation deserve their own check. |
| After every StartEmergency, notification, StopConveyor, StopLoading, and a valid reset remain reachable. | S10 can hold in a permanently stuck emergency, and F9 can pass if reset is unreachable. Use possibility unless operator/fairness assumptions justify inevitability. |
| After every transfer, customer collection remains reachable. | F5 only orders gate commands. A box could satisfy that ordering while never allowing the customer to take the plate. |
| Every started servicing round can reach all three completions or be cancelled by emergency notification. | S8 counts reports and guards movement, but does not require eventual completion or cancellation. A guarantee on every execution would need explicit progress assumptions. |

A useful small suite retains S1–S5, operational S6, S7, S8/S9, S10/S12,
F1–F3, revised F4, F6–F9, plus conservation and emergency-recovery reachability.
Treat S11 as a named emergency instance of S1 and F5 as an explicit sequence
regression if you want to avoid duplicate core requirements.

All verification is for six slots and three total accepted orders. This is a
finite instance, not a proof for arbitrary restaurant capacity or an unbounded
stream of orders. The original full F7 collection formula is preferable when
changing that bound or allowing order IDs to be reused.
If IDs are reused, S7 must distinguish order occurrences rather than treating a
recycled number as the same order for the system's entire lifetime.
