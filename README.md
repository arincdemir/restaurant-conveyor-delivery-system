# Restaurant conveyor delivery system

Current report and verified mCRL2 model for the 2IMF30 project. The instance has
six belt positions, two tables and three total accepted orders.

## Start here

- [Read the report PDF](report/secure_restaurant_conveyor.pdf).
- [Edit the report LaTeX](report/secure_restaurant_conveyor.tex).
- Open restaurant-conveyor-delivery-system.mcrl2proj in the mCRL2 IDE.
- [Requirements and property catalog](properties/CATALOG.md): R1-R14, all selected checks PASS.
- [Native verification instructions](properties/NATIVE_VERIFICATION.md).
- [Results, timings, hashes and native evidence](verification/README.md).

## Build the report

Install a LaTeX distribution with latexmk and the packages declared by the source,
then run from the repository root:

```sh
cd report
latexmk -pdf -outdir=build -interaction=nonstopmode -halt-on-error secure_restaurant_conveyor.tex
cp build/secure_restaurant_conveyor.pdf secure_restaurant_conveyor.pdf
```

The source reads the root model and properties/R1.mcf through R14.mcf directly.
Keep the three verification-*.tex companions beside it. No external source folders,
Python verification runner, generated graph or PBES files are needed to compile.
All local evidence links resolve within this repository. Historical absolute
working directories in the method section record the original run only.

## Make changes

The English requirements in properties/requirements.json match the report.
Update both if the wording changes. Changes to the model or formulas require new
verification; previously recorded PASS results do not automatically apply.
The source hashes in verification/inputs.sha256 identify the checked revision.
See properties/SEMANTICS.md for capability versus universal progress and the R12
order-ID guard. Original R12 attempts and its isolated diagnostic are separate
from the fourteen selected successful checks.

## Repository contents

- Root .mcrl2/.mcrl2proj: current model and IDE project.
- properties/: current requirements, fourteen formulas and explanations.
- report/: portable LaTeX sources, supporting tables and compiled PDF.
- verification/: compact native evidence and the R12 diagnostic.
- scripts/verify-report-native.sh: optional sequential native command runner.

Generated graphs, PBESs, compiler artifacts, local campaigns and obsolete drafts
are ignored rather than deleted from the author's machine. Previously committed
S/F properties and old proposals remain available in Git history.
