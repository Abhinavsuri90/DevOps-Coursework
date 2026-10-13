#!/usr/bin/env bash
# Evidence recorder used for the session transcripts.
# Student: Abhinav
#
# Usage:
#   source scripts/evidence.sh
#   EVIDENCE=session-13-storage-hpa-probes/evidence/hpa.txt
#   run kubectl get hpa
#   note "Waiting 60s for metrics"
#
# Every command is written to $EVIDENCE as "$ <command>" followed by its real
# stdout/stderr, so each PNG in the screenshots folders can cite exact lines.

run() {
  : "${EVIDENCE:?set EVIDENCE to the transcript file first}"
  mkdir -p "$(dirname "$EVIDENCE")"
  printf '$ %s\n' "$*" >> "$EVIDENCE"
  printf '$ %s\n' "$*"
  { eval "$*"; } 2>&1 | tee -a "$EVIDENCE"
  return "${PIPESTATUS[0]}"
}

note() {
  : "${EVIDENCE:?set EVIDENCE to the transcript file first}"
  mkdir -p "$(dirname "$EVIDENCE")"
  printf '# %s\n' "$*" | tee -a "$EVIDENCE"
}
