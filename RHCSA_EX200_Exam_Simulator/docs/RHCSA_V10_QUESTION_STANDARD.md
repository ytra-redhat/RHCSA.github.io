# RHCSA v10 question and hint standard

## Question stem

A task states only:

1. the required end state;
2. the exact resource names, paths, accounts, services, addresses, sizes, or modes needed to obtain that state;
3. whether the result must survive reboot when persistence is part of the objective.

A task does not state the complete command, command sequence, or verification implementation. Boilerplate such as “the task is complete when” is prohibited.

## Hints

- Difficulty 1–2: identify the command family or one key concept.
- Difficulty 3: identify the subsystem and a verification direction.
- Difficulty 4–5: point to the relevant manual page or diagnostic layer.
- Never include the complete reference command in a hint.

## Lab types

- `drill`: focused existing practice task.
- `exam`: dedicated objective-level scenario.
- `integrated-exam`: multi-objective chapter scenario.
- `guided-manual`: task that requires reboot, GRUB, or another action that cannot safely be automated in the browser session.

## Validation

`question_quality.py` checks length, ambiguity, answer-revealing hints, output destinations, metadata, and the presence of a reference command. `objective_coverage.py` checks official-objective coverage, difficulty spread, state-changing work, exam-grade work, and persistence.
