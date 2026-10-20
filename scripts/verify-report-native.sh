#!/bin/bash
# Native mCRL2 campaign. This script only sequences, times and logs commands.
# Usage: bash verify-report-native.sh /absolute/path/to/frozen-campaign
# The frozen campaign contains the model, properties/, and an empty run/.
set -u
campaign=$1
cd "$campaign/run" || exit 1
if [ -e ../results.tsv ] || [ -e ../stages.tsv ]; then
    printf 'Choose a fresh verification directory; refusing to overwrite prior records.\n' >&2
    exit 1
fi
date -u +%FT%TZ > ../started-utc.txt
mkdir -p ../logs
printf 'scope\tstage\texit_code\treal_seconds\tcommand\n' > ../stages.tsv
printf 'requirement\toutcome\ttotal_seconds\tevidence\n' > ../results.tsv
printf '%s\n' "$PWD" > ../working-directory.txt
: > ../commands.log

now() { /usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time'; }
elapsed() { /usr/bin/perl -e 'printf "%.3f", $ARGV[1]-$ARGV[0]' "$1" "$2"; }
stage() {
    scope=$1
    name=$2
    shift 2
    log="../logs/$scope.$name.log"
    printf '%s %s\n' "$scope" "$name" > ../CURRENT
    printf '%s %s: ' "$(date -u +%FT%TZ)" "$scope/$name"
    printf '%q ' "$@"
    printf '\n'
    printf '%q ' "$@" >> ../commands.log
    printf '\n' >> ../commands.log
    /usr/bin/time -p "$@" > "$log" 2>&1
    code=$?
    seconds=$(awk '$1 == "real" && NF == 2 {v=$2} END {print v}' "$log")
    printf '%s\t%s\t%s\t%s\t' "$scope" "$name" "$code" "$seconds" >> ../stages.tsv
    printf '%q ' "$@" >> ../stages.tsv
    printf '\n' >> ../stages.tsv
    printf '%s exit=%s real=%ss\n' "$scope/$name" "$code" "$seconds"
    return "$code"
}

graph_start=$(now)
graph_ok=true
stage graph mcrl22lps mcrl22lps --lin-method=regular ../restaurant-conveyor-delivery-system_spec.mcrl2 model.lps &&
stage graph lpsconstelm lpsconstelm model.lps model.const.lps &&
stage graph lpssumelm lpssumelm model.const.lps model.ready.lps &&
stage graph lps2lts lps2lts --cached --rewriter=jittyc --verbose model.ready.lps complete.lts &&
stage graph ltsconvert ltsconvert --equivalence=bisim complete.lts reduced.lts || graph_ok=false
graph_end=$(now)
elapsed "$graph_start" "$graph_end" > ../graph-total-seconds.txt
if [ "$graph_ok" = true ]; then
    stage metadata complete-info ltsinfo complete.lts
    stage metadata reduced-info ltsinfo reduced.lts
fi

for number in {1..14}; do
    req=R$number
    start=$(now)
    outcome=INCONCLUSIVE
    if [ "$graph_ok" = true ]; then
        if stage "$req" lts2pbes lts2pbes --verbose --preprocess-modal-operators --formula=../properties/$req.mcf reduced.lts $req.pbes &&
           stage "$req" pbesrewr pbesrewr --verbose --pbes-rewriter=quantifier-one-point $req.pbes $req.one.pbes &&
           stage "$req" pbesparelm pbesparelm --verbose $req.one.pbes $req.optimized.pbes &&
           stage "$req" pbessolve pbessolve --verbose --rewriter=jittyc --solve-strategy=0 $req.optimized.pbes; then
            answer=$(awk '$0 == "true" || $0 == "false" {v=$0} END {print v}' "../logs/$req.pbessolve.log")
            case "$answer" in
                true) outcome=PASS ;;
                false) outcome=FAIL ;;
            esac
        fi
    fi
    finish=$(now)
    duration=$(elapsed "$start" "$finish")
    printf '%s\t%s\t%s\tlogs/%s.*.log\n' "$req" "$outcome" "$duration" "$req" >> ../results.tsv
    printf '%s %s total=%ss\n' "$req" "$outcome" "$duration"
done
date -u +%FT%TZ > ../finished-utc.txt
printf 'COMPLETE\n' > ../CURRENT
