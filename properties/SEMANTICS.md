# How to explain the compact properties

The requirements in the report and requirements.json are authoritative for this
suite. Each R file quotes that wording and comments every independent clause.

## Three main patterns

- `[true* . A . (!B)* . C] false`: after A, C cannot happen before B.
- `[true* . A] <... . B> true`: after every A, there is a path to B.
- `mu Finish . (<true> true && [!goal] Finish)`: every continuation must eventually
  reach the goal. The enabled-action test makes a deadlock fail too.

R14 is `[true*] <true> true`. It forbids deadlocks but allows enabled customer
or operator actions to supply the next step. It does not imply eventual service.

R7 uses the third pattern with advancement or a new emergency as its goal.
Its revised station-completion clause checks each of the three reporting stations
with stages 0 (no current stop), 1 (waiting for completion), and 2 (completed).
The synchronized round begins a stop. Both successful work and a skip end with
`StationDone`; `SendSkip` alone does not acknowledge completion. Start and advance
require stage 2 for every station. Advancement, emergency request and reset clear
the old stop, and a fresh round requires fresh reports. This adds the current-stop
completion barrier; it does not audit every skip decision or duplicate report.
R11–R13 use the second pattern. Their English says **can**: a successful path
exists, rather than every execution eventually succeeding. Preparation,
collection and operator clearance may occur on such a path; no human fairness
or continued advancement is assumed.

R13's formula additionally excludes dependence on customer collection, which
is stronger than its English requirement. R7, including its current-stop
completion barrier and universal stop-progress clause, returned a fresh native
PASS in the whole-formula report campaign. See [CATALOG.md](CATALOG.md) and the
[fresh evidence](../verification/README.md); historical
answers and timings are not substituted.

## Small local memories

R4 remembers one Boolean: whether this stop's loading-slot snapshot confirmed an
empty slot. Loading consumes that confirmation, and advance/reset invalidates it.
The source sends the live belt slot at the synchronized round event. This check
uses that interface; it does not reconstruct all six belt positions.

R6 remembers one aligned PlateSlot, supplied by the current round. Delivery must
consume that exact plate, and advancement/reset invalidates the snapshot.
Its other clauses separately check stopped movement, gates and retraction.

R10 remembers one phase: 0 normal, 1 requested, 2 all controllers notified,
3 operator cleared. Reset is allowed only in phase 3 and returns to phase 0.
Physical readiness fields and real button wiring are not independently audited.

R11 remembers only the next order number because AcceptOrder exposes its meal
and table but not its assigned ID. The model allocates IDs 0, 1, 2 in acceptance
order. This single counter supports a possible loading path; it is not a full
proof relating every accepted order to every future plate on every execution.

R12's first conjunct quantifies over the three IDs that can actually be loaded,
using `val(oid < maxOrders) =>`. The model already guards loading with that bound,
so IDs outside it cannot trigger the obligation. This user-approved revision
preserves the capability requirement on the bounded model. The original
attempt without an explicit ID guard was interrupted without an answer and remains INCONCLUSIVE;
its logs and the separate revised check are retained in the fresh campaign.

## Initial state and synchronized events

The inner gates initially are open; outer gates are closed. The belt and boxes
are empty, pushers retracted, belt stopped and operation normal. Initial-history
clauses are included where an earlier close/open/delivery cannot be assumed.

The formulas match the complete synchronized events:

- load: `LoadPlate(id) | PlateLoaded(plate(...))`;
- delivery: `Push(table) | BoxFilled(table) | PlateTransferred(table, plate(...))`;
- round: permission together with the loading slot and both table snapshots;
- notification: EmergencyReceived for all four controllers together;
- reset: EndEmergency with EmergencyCleared for all four controllers together.

BoxEmptied is collection. Gate closure alone does not empty a box. Retraction
alone does not remove a plate. Reset does not clear the at-most-once history.

## Scope choices

R2 trusts the plate tag. Correct kitchen tagging is assumed. Full accepted-order
identity, complete storage conservation, detailed skip/report accounting,
same-stop table independence and permission of every safe emergency action are
outside this suite. The model may implement those behaviours without this report
claiming that they were separately verified.

Results cover six positions, two tables, three total accepted orders, one Doner
meal value and atomic transfers. No physical timing, sensor failures, unbounded
capacity or guaranteed human participation is established.
