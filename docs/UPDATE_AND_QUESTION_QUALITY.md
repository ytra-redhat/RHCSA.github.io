# RHCSA simulator updates and question-quality standard

## Update source

All installation and update operations are locked to:

```text
https://github.com/ytra-redhat/RHCSA.github.io
branch main
```

No update code may download simulator files or questions from another GitHub
repository.

## Manual update commands

```bash
rhcsa update --check
rhcsa update --status
rhcsa update --changes
rhcsa update
```

`rhcsa update --check` exits with status 10 when a newer commit is available.
`rhcsa update` downloads the complete `main` archive, validates it, preserves
progress, installs atomically and rolls back if activation fails.

## Automatic updates

`rhcsa-update.timer` checks GitHub every 30 minutes, with a randomized delay.
The updater compares the installed commit in `/usr/local/share/rhcsa/.version`
with the newest commit on `main`. When they differ it requests GitHub's compare
API, records the changed filenames and runs the same transactional installer.

State and logs:

```text
/var/lib/rhcsa/update-state.json
/var/log/rhcsa/update.log
```

The Web UI shows the installed and remote commits, the changed filenames and
the update result.

## Question-quality requirements

Every task question must state:

1. the action to perform;
2. every exact source resource, account, package, service or path needed;
3. the exact output path or requested final state;
4. whether output must overwrite, append, or capture stderr;
5. a concrete success condition.

A question may not rely on vague references such as “it”, “its”, “both
values”, “a missing path” or “the file” unless the referenced object is named
in the same sentence.

Every hint must contain:

- a suggested command or ordered command sequence;
- an explanation of the important option, redirection operator or state change;
- enough information to understand why the command satisfies the task.

Audit command:

```bash
python3 RHCSA_EX200_Exam_Simulator/scripts/question_quality.py \
  RHCSA_EX200_Exam_Simulator/questions
```

The release validator runs this audit automatically. A release with ambiguous
questions or non-explanatory hints is rejected.
