# Shell Scripting

Student: **Abhinav**

The executable script [`system-info.sh`](system-info.sh) fulfills all homework tasks: it prints current date, hostname, username, disk space usage, and active processes; uses shell variables for data handling; collects interactive user input with `read -p`; creates directories and files using `mkdir` and `touch`; and redirects process logs to disk using `>`.

## 1. Run Command

```bash
chmod +x system-info.sh
./system-info.sh
```

Example interactive input:

```text
Enter a directory name to create: system-info-output
Enter an output file name for process listing: processes.txt
```

## 2. Real Captured Execution Output

```
==========================================
         SYSTEM INFORMATION SCRIPT        
==========================================
Date     : Sat Sep  5 00:02:22 IST 2026
Hostname : Abhinavs-MacBook-Air-2.local
User     : abhinavsuri
==========================================

--- Disk Usage ---
Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5   460Gi   254Gi   167Gi    61%    2.8M  1.8G    0%   /System/Volumes/Data

Created directory: system-info-output
Created file: system-info-output/processes.txt
--- Fetching Running Processes ---
Running processes successfully saved to system-info-output/processes.txt.

First 5 lines of saved file:
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
root              3299  37.0  0.4 435342720  35488   ??  Ss   12:02AM   0:00.15 /System/Library/PrivateFrameworks/...
_windowserver      412  27.2  0.5 436553408  42560   ??  Ss   11:17PM   5:54.90 /System/Library/PrivateFrameworks/...
abhinavsuri       2443  24.0  5.0 1894076144 420064   ??  S    11:36PM   1:22.97 /Applications/Antigravity IDE.app/...
_reportmemoryexception 3292 10.6 0.1 435343920 11872  ??  Ss   12:02AM   0:00.25 /usr/libexec/ReportMemoryException
```

## 3. What I Learned

- **Variable Quoting:** Quoting variables (e.g., `"${TARGET_DIR}"`) prevents word splitting and glob expansion if user input contains spaces.
- **Idempotent Directories:** Using `mkdir -p` ensures directory creation succeeds silently even if the folder already exists.
- **File Redirection:** `touch` creates an initial empty file placeholder, while `ps aux > file` replaces the file content with live process listings.
- **Script Robustness:** Including `set -euo pipefail` ensures immediate failure detection on non-zero command exits or uninitialized variable accesses.
