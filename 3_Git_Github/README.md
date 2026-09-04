# Task 1

```
…/practice/git_practice ❯ git init .
Initialized empty Git repository in /home/adam/practice/git_practice/.git/

git_practice master ❯ touch test.txt

git_practice master ? ❯ echo "First version" > test.txt

git_practice master ? ❯ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	test.txt

nothing added to commit but untracked files present (use "git add" to track)

git_practice master ? ❯ git commti -m "Add test file"
git: 'commti' is not a git command. See 'git --help'.

The most similar command is
	commit

git_practice master ? ✗ git commit -m "Add test file"
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	test.txt

nothing added to commit but untracked files present (use "git add" to track)

git_practice master ? ✗ git add test.txt

git_practice master ❯ git commit -m "Add test file"
[master (root-commit) 3a1386d] Add test file
 1 file changed, 1 insertion(+)
 create mode 100644 test.txt

git_practice master ❯ echo "second version" >> test.txt

git_practice master  ❯ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")

git_practice master  ❯ git commit -a -m "update test file"
[master 56d0d0e] update test file
 1 file changed, 1 insertion(+)

git_practice master ❯ git log --oneline
56d0d0e (HEAD -> master) update test file
3a1386d Add test file

git_practice master ❯ touch new.tx

git_practice master ? ❯ git commit -a -m "add new file"
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	new.tx

nothing added to commit but untracked files present (use "git add" to track)

```
# Task 2 
```

…/practice/git_practice_2 ❯ git init -b main
Initialized empty Git repository in /home/adam/practice/git_practice_2/.git/

git_practice_2 main ❯ echo "Project started" > project.txt

git_practice_2 main ? ❯ git add project.txt 

git_practice_2 main ❯ git commit -m "Start project"
[main (root-commit) f4241c1] Start project
 1 file changed, 1 insertion(+)
 create mode 100644 project.txt

git_practice_2 main ❯ echo "Feature A" >> project.txt

git_practice_2 main  ❯ git add project.txt

git_practice_2 main ❯ git commit -m "Add feature A"
[main 862f00d] Add feature A
 1 file changed, 1 insertion(+)

git_practice_2 main ❯ echo "Feature B" >> project.txt 

git_practice_2 main  ❯ git add project.txt 

git_practice_2 main ❯ git commit -m "Add feature B"
[main 46c950c] Add feature B
 1 file changed, 1 insertion(+)

git_practice_2 main ❯ git log --oneline
46c950c (HEAD -> main) Add feature B
862f00d Add feature A
f4241c1 Start project

git_practice_2 main ❯ git switch -c feature-branch
Switched to a new branch 'feature-branch'

git_practice_2 feature-branch ❯ git branch
* feature-branch   main

git_practice_2 feature-branch ❯ echo "Feature branch work 1" >> project .txt

git_practice_2 feature-branch ? ❯ git add project 

git_practice_2 feature-branch ❯ ls
Permissions Size User Date Modified Name
.rw-r--r--    27 adam  4 Sep 22:44  󰡯 project
.rw-r--r--    36 adam  4 Sep 22:43   project.txt

git_practice_2 feature-branch ❯ git restore --staged --worktree project

git_practice_2 feature-branch ❯ ls
Permissions Size User Date Modified Name
.rw-r--r--    36 adam  4 Sep 22:43   project.txt

git_practice_2 feature-branch ❯ echo "Feature branch work 1" >> project.txt

git_practice_2 feature-branch  ❯ git add project.txt 

git_practice_2 feature-branch ❯ git commit -m "Feature branch change 2"
[feature-branch 0b73da4] Feature branch change 2
 1 file changed, 1 insertion(+)

git_practice_2 feature-branch ❯ echo "Feature branch work 3" >> project.txt 

git_practice_2 feature-branch  ❯ git add project.txt 

git_practice_2 feature-branch ❯ git commit -m "Feature branch change 3"
[feature-branch 8a1449d] Feature branch change 3
 1 file changed, 1 insertion(+)

git_practice_2 feature-branch ❯ git log --oneline
8a1449d (HEAD -> feature-branch) Feature branch change 3
0b73da4 Feature branch change 2
46c950c (main) Add feature B
862f00d Add feature A
f4241c1 Start project

git_practice_2 feature-branch ❯ git switch main
Switched to branch 'main'

git_practice_2 main ❯ git log --oneline
46c950c (HEAD -> main) Add feature B
862f00d Add feature A
f4241c1 Start project

git_practice_2 main ❯ git cherry-pick 0b73da4
[main d0e5ef9] Feature branch change 2
 Date: Fri Sep 4 22:46:48 2026 +0530
 1 file changed, 1 insertion(+)

git_practice_2 main ❯ git log --oneline
d0e5ef9 (HEAD -> main) Feature branch change 2
46c950c Add feature B
862f00d Add feature A
f4241c1 Start project

git_practice_2 main ❯ cat project.txt 
Project started
Feature A
Feature B
Feature branch work 1
```
