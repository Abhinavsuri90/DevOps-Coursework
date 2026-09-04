# Git and GitHub Homework

Student: **Abhinav**

This module documents practical exercises comparing Git commit options and applying specific commits across branches using `git cherry-pick`. All command sequences were run live in terminal.

## 1. `git commit -m` vs `git commit -a -m`

- **`git commit -m "message"`**: Commits only the changes that have been explicitly added to the Git staging area using `git add`.
- **`git commit -a -m "message"`**: Automatically stages modifications and deletions for **already tracked** files before committing. However, it explicitly skips new, **untracked** files (`??`).

### Observed Behavior Test

Before running `git commit -a -m`, the workspace contained one modified tracked file (`tracked-example.txt`) and one new untracked file (`untracked-example.txt`):

```bash
echo "Tracked content v2" >> tracked-example.txt
echo "Untracked content" > untracked-example.txt
git status -s
```

```
 M tracked-example.txt
?? untracked-example.txt
```

Executing `git commit -a -m "Demonstrate tracked-file auto staging"` produced:

```bash
git commit -a -m "Demonstrate tracked-file auto staging"
git status -s
```

```
[main b25b129] Demonstrate tracked-file auto staging
 1 file changed, 1 insertion(+)
?? untracked-example.txt
```

*In an interview I'd say:* `git commit -a` automatically stages modified tracked files before committing, but it will never stage untracked files—new files must always be explicitly staged with `git add`.

---

## 2. Git Cherry-Pick Exercise

`git cherry-pick` allows applying the exact change introduced by an existing commit on another branch onto the current working branch.

### Step-by-Step Execution

1. Created a practice feature branch `cherry-pick-practice` from `main`:
   ```bash
   git checkout -b cherry-pick-practice
   ```
2. Added feature commits on `cherry-pick-practice`:
   ```bash
   echo "Feature notes" > feature.txt && git add feature.txt && git commit -m "Add feature notes"
   echo "Important fix" > cherry-picked-change.txt && git add cherry-picked-change.txt && git commit -m "Add important hotfix for main"
   echo "Extra work" > extra.txt && git add extra.txt && git commit -m "Add branch-only work"
   ```
3. Returned to `main` branch and cherry-picked target commit `a21c2b5`:
   ```bash
   git checkout main
   git cherry-pick a21c2b5
   ```
4. Verified commit history graph with `git log --oneline --graph --all`:

```
* a1143d1 (cherry-pick-practice) Add branch-only work
* a21c2b5 Add important hotfix for main
* af81bab Add feature notes
| * 25adfa2 (main) Add important hotfix for main
|/  
* c8c9108 Commit untracked file
* b25b129 Demonstrate tracked-file auto staging
* 1691e47 Initialize tracked file
```

The file [`cherry-picked-change.txt`](cherry-picked-change.txt) is now present on `main` (commit `25adfa2`), while `feature.txt` and `extra.txt` remain isolated on `cherry-pick-practice`.

*In an interview I'd say:* `git cherry-pick` selectively copies a specific commit from one branch to another by applying its patch as a brand-new commit with a new hash on the target branch.
