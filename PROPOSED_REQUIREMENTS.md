# Proposed restaurant conveyor requirements

The kitchen sends plates around a looping conveyor to two tables. Each table has
a one-plate delivery box. Its **belt-side (inner) gate** faces the conveyor; its
**customer-side (outer) gate** faces the customer. A pusher moves a plate into
the box and then returns to its resting position.

**Delivered** means placed in the box; **collected** means taken by the customer.
An **available box** is empty with its customer-side gate closed. A **servicing
round** is the work done at one belt stop: the kitchen and both tables each load,
receive, or skip, then report completion.

An **approved reset** needs staff clearance and readiness from the conveyor,
kitchen loader, and both boxes. **Can** means an outcome is possible.
**Eventually** means it must happen later under the stated conditions; it has no
fixed time limit. Conditions for a guarantee refer to the same course of operation.

The current model uses six belt positions, three total accepted orders, and
unordered kitchen loading. Transfers into boxes are single complete steps;
partly transferred plates and mechanical faults are outside this abstraction.
These bounds and abstractions are separate from the requirements.

## Orders and safe operation

### R1 - Separate the two gates

The two gates of a delivery box must never be open together, including during an emergency or reset.

### R2 - Match the order and table

Each accepted order has a unique number. A prepared or loaded plate must match that order and its destination, and may be delivered only to that table.

### R3 - Process each order once

Each order may be prepared, loaded, and delivered at most once, including across emergencies and resets.

### R4 - Preserve orders and plates

Prepared plates must not be lost or duplicated before collection. Emergencies and resets must preserve outstanding orders and remaining plates.

### R5 - Load safely

The kitchen may load only into an empty loading position, while the belt is stopped and the kitchen is working on the current servicing round.

### R6 - Start a push safely

A push may start only with the belt stopped, the correct plate aligned, the box empty, the belt-side gate open, and the customer-side gate closed.

### R7 - Return the pusher first

The pusher must return to its resting position before the belt-side gate closes or the belt starts moving again.

### R8 - Collect safely

Customers may collect only from an occupied box with its customer-side gate open and belt-side gate closed.

### R9 - Report the current round

Each station reports completion once, after finishing its round work and safety steps; a skipped station sends one skip first. Replies must belong to the current round. Emergency notification may cancel outstanding replies; reset starts a fresh round without reusing old replies.

### R10 - Wait before moving

The belt may start or advance only after all three current-round completion replies, with all pushers retracted and all belt-side gates closed.

## Emergency handling and reset

### R11 - Accept emergency requests promptly

An emergency request must be accepted without first finishing a delivery or the current servicing round.

### R12 - Block unsafe work immediately

From an emergency request until approved reset, no belt start or advance, loading, push initiation, belt-side gate opening, order acceptance, or new servicing round is allowed. Safe finishing actions and dispatch of accepted orders remain allowed.

### R13 - Reset only when approved and safe

Reset requires operator approval and the conveyor, kitchen loader, and both boxes notified and ready: belt and loading stopped, pushers retracted, belt-side gates closed, and customer-side gates open. Boxes may still contain plates.

### R14 - Keep recovery possible

After every emergency request, notification of all four receiving controllers, stopping, safe recovery, and an approved reset must remain possible.

## Delivery and progress

### R15 - Prepare and load accepted orders

For every accepted order, preparation and loading onto an empty belt position must be possible during normal operation, without requiring an emergency or reset.

### R16 - Deliver when the box is available

At a normal stop, a plate beside its destination box must be able to enter before the belt advances if the box is empty and its customer-side gate is closed. No emergency or reset is needed.

### R17 - Skip without blocking the belt

In normal rounds, a table skips an empty slot, a plate for another table, an occupied box, or an open customer-side gate. A skipped plate remains on the belt; an occupied box must not require collection before the belt can continue.

### R18 - Let either table go first

When both correct plates are aligned at available boxes, both transfers must be possible in either order during the same stopped round, provided no emergency occurs.

### R19 - Keep collection possible

After delivery, the system must be able to finish its pusher and gate actions and allow collection, including during emergency recovery before reset.

### R20 - Make the box available again

With continued normal operation, collection must be followed by customer-side gate closure and renewed box availability. During an emergency, closure may wait until approved reset.

### R21 - Eventually deliver circulating plates

If the belt keeps advancing and every other plate occupying a destination box is eventually collected, each loaded plate for that box must eventually be delivered there.

### R22 - Avoid deadlocks

The system must never reach a situation with no permitted action. Waiting for a customer or operator is allowed if they have an available action.

### R23 - Resume after reset

After every approved reset, a normal servicing round and belt advancement must be possible without another emergency.

### R26 - Finish normal rounds

At the start of every normal servicing round, it must be possible to finish it and advance the belt without requiring an emergency or customer collection.

Numbering retains the approved proposal IDs; R24 and R25 are not included.
