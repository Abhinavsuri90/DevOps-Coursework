#!/usr/bin/env python3
"""Show (or wait for) the GitHub Actions run of a workflow for one commit, using the public API.

Student: Abhinav

No token is needed for a public repository. Prints the run's result, its URL and every job.

Usage:
  python3 scripts/gh-run-status.py <commit-sha> "<workflow name>" [--wait]
  python3 scripts/gh-run-status.py "$(git rev-parse HEAD)" "Final project · SpendWise CI/CD" --wait
"""

import json
import subprocess
import sys
import time

REPO = "Abhinavsuri90/DevOps-Coursework"
POLL_SECONDS = 45  # unauthenticated API calls are limited to 60 per hour


def get(url):
    # curl uses the system certificate store (python.org builds on macOS often have none configured).
    output = subprocess.run(["curl", "-fsSL", "--max-time", "30", url], check=True, capture_output=True, text=True)
    return json.loads(output.stdout)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    sha, name, wait = sys.argv[1], sys.argv[2], "--wait" in sys.argv[3:]
    started = time.time()
    while True:
        runs = get(f"https://api.github.com/repos/{REPO}/actions/runs?head_sha={sha}&per_page=20")
        matching = [run for run in runs.get("workflow_runs", []) if run["name"] == name]
        if matching and (matching[0]["status"] == "completed" or not wait):
            break
        if not wait:
            sys.exit(f"no '{name}' run found for {sha}")
        time.sleep(POLL_SECONDS)
    run = matching[0]
    waited = f" (waited {int(time.time() - started)}s)" if wait else ""
    print(f"{run['name']} on {run['head_sha'][:12]}: {run['status']} / {run['conclusion']}{waited}")
    print(run["html_url"])
    for job in get(run["jobs_url"] + "?per_page=50")["jobs"]:
        print(f"  {job['conclusion'] or job['status']:>9}  {job['name']}")


if __name__ == "__main__":
    main()
