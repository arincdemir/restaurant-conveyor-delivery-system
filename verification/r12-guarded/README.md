# R12 with the explicit order-ID guard

The selected R12 is properties/R12.mcf at the repository root. It returned true
in 492.164 seconds across the four native commands, with 131.87 seconds in the
solver. Its model and formula hashes are recorded in input-sha256.txt. Historical
paths in that manifest refer to the original isolated run.

Loading already requires oid < maxOrders in the model, so adding that guard to
the formula leaves its meaning unchanged on this model. Both formulas use the
same three-order model. Original attempts without the guard remain INCONCLUSIVE.

The original successful attempt reused the full batch's freshly generated strong
bisimulation quotient, with identical model and graph hashes. It used the same
four commands and flags, with no conjunct splitting or additional action hiding.
The full generated intermediates remain local and are not needed in Git.
