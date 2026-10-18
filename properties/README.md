# Emergency and delivery properties

These properties use the S1–S12 / F1–F9 numbering from the requirements. They
observe the complete system's actions. The model and its behaviour are unchanged
by adding the formulas.

The complete set is listed in [CATALOG.md](CATALOG.md), with links to expressive
and short versions. [REQUIREMENTS_REVIEW.md](REQUIREMENTS_REVIEW.md) gives concise
wording for every requirement, explains overlaps and limitations, and suggests
useful additions. The sections below document the original emergency/F7 group.

Results for that group before the direct-emergency refactor (2026-10-17):

| Check | Result |
| --- | --- |
| S10 | true |
| S11 | true |
| S12 | true |
| F7 as written | false |
| F7 with the additional collection assumption | true |
| F9 | true |

| File | Meaning |
| --- | --- |
| `S10_noUnsafeActionsDuringEmergency.mcf` | Between `StartEmergency` and the complete synchronized reset, forbid loading, pushing, inner-gate opening, advancement and conveyor start. |
| `S11_emergencyGateInterlock.mcf` | Opening either gate requires its paired gate to be closed. This checks the interlock throughout operation, including emergency release. |
| `S12_noAutomaticResume.mcf` | Recovery requires emergency notification, explicit operator clearance and synchronized reset. Normal admission, servicing and unsafe operations remain inhibited until reset. |
| `F7_eventualDelivery.mcf` | On every execution where the belt advances infinitely often and a loaded plate's destination box is available at least once afterwards, that plate is eventually delivered. |
| `F7_eventualDeliveryWithCollection.mcf` | The same F7 requirement, with the additional assumption that every plate occupying the destination box is eventually collected. |
| `F9_resumeAfterReset.mcf` | After every synchronized reset, conveyor advancement remains possible. This existing formula is unchanged. |

## Important interpretations

- The emergency interval begins at `StartEmergency`, before the deferred
  `EmergencyReceived` broadcast.
- Controllers now receive that broadcast directly before blocked unsafe actions.
  Notification cancels the unfinished servicing round; reset begins a fresh round.
  Already-started transfers finish retracting, closing their inner gate, and
  reporting before notification. Prepared food is retained. The S8 formulas
  permit emergency cancellation while still requiring every reply before advance.
- The refactor's checks are recorded in
  [the verification notes](../../output/verification/direct-emergency-2026-10-18/verification-notes.md).
- A reset is the single multi-action containing `EndEmergency` and all four
  `EmergencyCleared` results. S12 also checks the preceding notification and
  `OperatorClearEmergency`. Normal operation may resume after that reset;
  there is no separate manual start button in this model.
- Loading is observed as `LoadPlate | PlateLoaded`; delivery is observed as
  `Push | BoxFilled | PlateTransferred`, with matching order and table data.
- The gate formulas start with the model's initial inner-open, outer-closed
  state. F7 starts with empty boxes and closed outer gates.
- An available box is empty with its outer gate closed. F7 permits this
  condition to hold already when loading occurs.
- Both F7 versions check universal eventual delivery under their assumptions.
  They do not merely check whether some successful delivery path exists.
- Infinite advancement and the other F7 assumptions must hold on the same
  execution. The formulas do not introduce fairness into the model itself.
- In the stronger F7 version, every blocking plate being eventually collected
  means that the box is empty infinitely often along an infinite execution.
  A box that stays empty satisfies this condition. It does **not** require
  infinitely many collection actions, which would be impossible with three
  total orders.

## Why F7 as written can fail

All three orders can target Table 1 and load in the order 0, 2, 1. Order 0 is
delivered and collected, making the box available after order 1 was loaded.
Order 2 then reaches the box first and is never collected. Order 1 can keep
circulating while the belt keeps advancing.

This meets the original F7 assumptions but prevents order 1's delivery. The
additional collection assumption excludes this execution because order 2
remains in the box forever.

## Shorter alternatives

Each formula also has a separately registered `_short.mcf` version. The original
files remain unchanged. The line counts below include explanatory comments.

| Property | Original lines | Short version lines | How it is shorter |
| --- | ---: | ---: | --- |
| S10 | 16 | 8 | Same formula, more compact layout. |
| S11 | 16 | 8 | Rules forbidding one gate opening before the other closes. |
| S12 | 43 | 24 | Four recovery stages replace three Boolean flags. |
| F7 as written | 46 | 23 | Action histories identify when a box is available. |
| F7 with collection | 69 | 23 | Available opportunities must eventually serve a plate; the finite number of plates makes repeated opportunities sufficient. |
| F9 | 8 | 4 | Same formula, more compact layout. |

The shorter versions retain the original meanings on the current model. Both
short F7 formulas still check **every execution satisfying the assumptions**;
they do not replace eventual delivery with the possibility of delivery.

Short F7 uses two facts checked separately on the complete model:
`CloseOuterGate` happens only with an empty box, and `BoxEmptied` happens only
with the outer gate open. These let the formula recognize availability from
action histories instead of tracking the box with Boolean parameters.

The short collection version additionally relies on the current finite order
bound and each order being transferred at most once. Other plates can consume
only finitely many available opportunities. If they are all eventually collected
and advancement continues, the target plate must eventually get an opportunity
that no other plate takes. Continued advancement also forces an open outer gate
to close after collection; this was checked separately.

These are properties of the current model, not extra assumptions about its
environment. Use the full collection formula, or recheck the simplification, if
the model later admits an unbounded stream of orders or repeated transfers.
The short versions have the same verification results shown above.
Fewer lines do not necessarily make verification faster: the short S11 and F7
formulas generate more checking equations than the original versions. The
originals remain useful for routine verification.

## Running the checks

All 44 formulas are registered in the project, including both F7 interpretations
and their short alternatives. Reload the project if it was
already open in the IDE, then select the property to verify. The existing
compiled-rewriter and enumeration-limit settings are preserved.

For command-line checking, translate a formula with `lps2pbes`, apply one-point
rewriting with `pbesrewr --pbes-rewriter=quantifier-one-point`, eliminate unused
parameters with `pbesparelm`, and solve with:

```sh
pbessolve --rewriter=jittyc --qlimit=10 --search-strategy=depth-first --solve-strategy=4 property-fast.pbes
```

The progress formulas can take longer than safety checks. A `false` result for
the original F7 is a requirement counterexample, rather than a compilation
failure.
