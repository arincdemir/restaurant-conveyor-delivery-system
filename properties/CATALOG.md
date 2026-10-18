# Property catalog

Expressive versions use descriptive monitors and comments. Short versions use
compact layout or equivalent action-history rules. Both preserve the documented
guarantee on the current six-slot, three-order model. The earlier short F7
collection variant uses verified finite-order facts; see README.md.
Line counts include comments.

The table records complete checks before the direct-emergency refactor
(2026-10-17, source `9fe01eda6fbc8e5953e11a4b476321ba7d001984b98d9c4e86b5845b81ab89ee`).
S8 has since been updated to allow emergency cancellation of an unfinished round.
See [the refactor's verification notes](../../output/verification/direct-emergency-2026-10-18/verification-notes.md)
for the checks rerun on the new source. “False” means a requirement does not hold;
a non-parseable formula is not counted as false.

| Requirement | Expressive version | Short version | Result |
| --- | --- | --- | --- |
| S1 | [16 lines](S1_gateInterlock.mcf) | [7 lines](S1_gateInterlock_short.mcf) | true |
| S2 | [6 lines](S2_correctDestination.mcf) | [3 lines](S2_correctDestination_short.mcf) | true |
| S3 | [10 lines](S3_noTransferIntoOccupiedBox.mcf) | [4 lines](S3_noTransferIntoOccupiedBox_short.mcf) | true |
| S4 | [36 lines](S4_safePusherOperation.mcf) | [28 lines](S4_safePusherOperation_short.mcf) | true |
| S5 | [14 lines](S5_safeConveyorAdvance.mcf) | [8 lines](S5_safeConveyorAdvance_short.mcf) | true |
| S6 | [17 lines](S6_noOccupiedSlotOverwrite.mcf) | [14 lines](S6_noOccupiedSlotOverwrite_short.mcf) | true |
| S7 | [12 lines](S7_atMostOnceDelivery.mcf) | [10 lines](S7_atMostOnceDelivery_short.mcf) | true |
| S8 | [30 lines](S8_oneReportPerRound.mcf) | [20 lines](S8_oneReportPerRound_short.mcf) | true |
| S9 | [31 lines](S9_roundAndMechanicalBarrier.mcf) | [26 lines](S9_roundAndMechanicalBarrier_short.mcf) | true |
| S10 | [16 lines](S10_noUnsafeActionsDuringEmergency.mcf) | [8 lines](S10_noUnsafeActionsDuringEmergency_short.mcf) | true |
| S11 | [16 lines](S11_emergencyGateInterlock.mcf) | [8 lines](S11_emergencyGateInterlock_short.mcf) | true |
| S12 | [43 lines](S12_noAutomaticResume.mcf) | [24 lines](S12_noAutomaticResume_short.mcf) | true |
| F1 | [15 lines](F1_acceptedOrderCanLoad.mcf) | [9 lines](F1_acceptedOrderCanLoad_short.mcf) | true |
| F2 | [21 lines](F2_alignedPlateCanDeliver.mcf) | [17 lines](F2_alignedPlateCanDeliver_short.mcf) | true |
| F3 | [22 lines](F3_occupiedBoxSkipsAndCanAdvance.mcf) | [14 lines](F3_occupiedBoxSkipsAndCanAdvance_short.mcf) | true |
| F4 (joint event) | [34 lines](F4_simultaneousTableTransfers.mcf) | [29 lines](F4_simultaneousTableTransfers_short.mcf) | false |
| F5 | [11 lines](F5_innerClosesBeforeOuterOpens.mcf) | [4 lines](F5_innerClosesBeforeOuterOpens_short.mcf) | true |
| F6 | [15 lines](F6_collectionClosesOuterGate.mcf) | [9 lines](F6_collectionClosesOuterGate_short.mcf) | true |
| F7 | [46 lines](F7_eventualDelivery.mcf) | [23 lines](F7_eventualDelivery_short.mcf) | false |
| F7 + collection | [69 lines](F7_eventualDeliveryWithCollection.mcf) | [23 lines](F7_eventualDeliveryWithCollection_short.mcf) | true |
| F8 | [8 lines](F8_deadlockFree.mcf) | [2 lines](F8_deadlockFree_short.mcf) | true |
| F9 | [8 lines](F9_resumeAfterReset.mcf) | [4 lines](F9_resumeAfterReset_short.mcf) | true |

F4 selects the strict simultaneous-transfer interpretation of “concurrent.” Its failure reflects the
current sequential conveyor updates and allow policy; it is not a syntax error.
The native model permits both transfer orders during one stopped round.
F7 as written fails because a different plate can take a briefly available box.

See [REQUIREMENTS_REVIEW.md](REQUIREMENTS_REVIEW.md) for interpretations, suggested
wording, overlaps, and additional requirements worth discussing. Safety checks
need not require eventual service; capability checks (`can`) need not require
service on every execution. F5 checks ordering, while F6 checks eventual closure.

Shorter formulas are not automatically faster. The earlier short S11/F7 variants
generate more checking equations than their expressive versions. Run large
progress checks sequentially to avoid memory pressure.
