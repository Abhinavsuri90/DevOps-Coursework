# Linux Fundamentals

Student: **Abhinav**

## 1. Soft Link & Hard Link

A soft link (symbolic link) is a shortcut that points to a target file path; it can cross file systems and breaks if the target file is renamed or deleted. A hard link points directly to the file's underlying inode on disk, sharing the exact same data and file content as the original. Consequently, deleting the original file does not delete the data as long as at least one hard link remains.

```bash
echo "DevOps link practice" > original.txt
ln -s original.txt soft-link.txt
ln original.txt hard-link.txt
ls -li original.txt soft-link.txt hard-link.txt
readlink soft-link.txt
rm soft-link.txt hard-link.txt original.txt
```

```
96028174 -rw-r--r--@ 2 abhinavsuri  staff  21 Sep  4 23:58 hard-link.txt
96028174 -rw-r--r--@ 2 abhinavsuri  staff  21 Sep  4 23:58 original.txt
96028175 lrwxr-xr-x@ 1 abhinavsuri  staff  12 Sep  4 23:58 soft-link.txt -> original.txt
original.txt
```

*In an interview I'd say:* A hard link points to the same inode on disk and retains data until all links are removed, whereas a soft link is a path pointer that breaks if the target file is removed or moved.

## 2. `adduser` vs `useradd`

`useradd` is a low-level, cross-distribution Linux command utility that creates user accounts without interactive prompts or default skeleton directory setups unless flags are explicitly provided. `adduser` is a high-level, interactive Perl wrapper script standard on Debian/Ubuntu that automatically creates home directories, sets default shell configs, and prompts for passwords interactively. On non-Linux host platforms (such as macOS Darwin), standard Linux shadow utilities are not present by default.

```bash
adduser coursework-user 2>&1 || useradd coursework-user 2>&1
```

```
zsh:1: command not found: adduser
zsh:1: command not found: useradd
```

*In an interview I'd say:* I prefer `adduser` for interactive user creation on Ubuntu due to its safe, user-friendly defaults, while `useradd` is preferred in non-interactive scripts for exact, low-level cross-distribution control.

## 3. `journalctl`

`journalctl` is the command-line utility used to query and view system log messages collected by the `systemd-journald` service in Linux distributions. It allows developers and sysadmins to inspect kernel logs, boot logs, and service-specific logs filtering by time, unit, or priority level. On macOS host environments or non-systemd container runtimes, `journalctl` is unavailable as systemd PID 1 is not running.

```bash
journalctl --no-pager -n 20 2>&1 || journalctl -u docker --no-pager 2>&1
```

```
zsh:1: command not found: journalctl
zsh:1: command not found: journalctl
```

*In an interview I'd say:* `journalctl` is the central systemd tool for filtering system logs by service unit (`-u`), severity (`-p`), or live tailing (`-f`) without manually searching log files.

## 4. Linux Command Cheat Sheet

Essential Linux commands provide foundational navigation, file management, process monitoring, and permission administration across server environments. Practice commands run locally demonstrate system path inspection, directory creation, file operations, permission setting, disk usage checks, and process listing.

```bash
pwd && ls -lah && mkdir -p demo && touch demo/file.txt && cp demo/file.txt demo/copy.txt && mv demo/copy.txt demo/moved.txt && chmod u+x demo/file.txt && df -h . && ps aux | head -n 5 && rm -rf demo
```

```
/Users/abhinavsuri/Desktop/DevOps-Coursework/linux-fundamentals
total 0
drwxr-xr-x@ 2 abhinavsuri  staff    64B Sep  4 23:58 .
drwxr-xr-x@ 3 abhinavsuri  staff    96B Sep  4 23:58 ..
Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5   460Gi   254Gi   167Gi    61%    2.8M  1.8G    0%   /System/Volumes/Data
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
abhinavsuri       2443  26.0  4.3 1892354096 361184   ??  S    11:36PM   0:52.57 /Applications/Antigravity IDE.app/...
_windowserver      412  15.9  0.6 436467920  48144   ??  Ss   11:17PM   5:29.79 /System/Library/PrivateFrameworks/...
abhinavsuri       2438   7.6  2.1 1892616592 175184   ??  S    11:36PM   0:36.19 /Applications/Antigravity IDE.app/...
```

| Purpose | Command |
| --- | --- |
| Current working directory | `pwd` |
| List files with details & hidden files | `ls -lah` |
| Navigate directories | `cd /path/to/dir` |
| Create directory & empty file | `mkdir demo && touch demo/file.txt` |
| Copy, move/rename, remove | `cp src dest`, `mv old new`, `rm file` |
| View & search file content | `cat file`, `less file`, `grep pattern file` |
| Change permissions & ownership | `chmod +x script.sh`, `chown user:group file` |
| Disk space & memory usage | `df -h`, `du -sh .`, `free -h` |
| Process listing & management | `ps aux`, `top`, `kill PID` |
| Archiving & compression | `tar -czvf archive.tar.gz directory` |
| Command documentation | `man command` or `command --help` |
