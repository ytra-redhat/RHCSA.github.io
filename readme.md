# RHCSA EX200 RHEL 10 Exam Simulator

This fork contains the RHCSA EX200 RHEL 10 simulator. Installation, reinstallation, questions, and updates use only:

```text
https://github.com/ytra-redhat/RHCSA.github.io
```

Branch: `main`.

## Coverage

- 62 official EX200 RHEL 10 objectives;
- 10 core objective chapters;
- 2 supplementary chapters for containers, installation, image mode, Cockpit, and subscriptions;
- 632 labs and 1,255 independently checked tasks;
- difficulty levels 1 through 5;
- dedicated objective labs and integrated chapter scenarios;
- machine-readable objective coverage and question-quality validation.

The chapter count is discovered dynamically. No installer or updater assumes a fixed number of chapters.

## Installation

```bash
curl -fsSL \
  https://raw.githubusercontent.com/ytra-redhat/RHCSA.github.io/main/Install_RHCSA_EX200_Exam_Simulator.sh |
sudo bash
```

The installer discovers the remote chapters, downloads one complete `main` archive, validates it, stages it, activates it atomically, and performs a real Web UI and terminal health check.

## Updates

```bash
rhcsa update --check
rhcsa update --changes
rhcsa update
rhcsa update --status
```

Updates compare the installed commit with `main`, report changed files, download and validate one coherent repository archive, preserve progress, and roll back on activation failure.

## Validation

```bash
python3 RHCSA_EX200_Exam_Simulator/scripts/validate_release.py .
python3 RHCSA_EX200_Exam_Simulator/scripts/objective_coverage.py \
  RHCSA_EX200_Exam_Simulator --json
python3 RHCSA_EX200_Exam_Simulator/scripts/question_quality.py \
  RHCSA_EX200_Exam_Simulator/questions --json
```

See:

- `RHCSA_EX200_Exam_Simulator/docs/RHCSA_V10_SOURCE_ANALYSIS.md`
- `RHCSA_EX200_Exam_Simulator/docs/RHCSA_V10_COVERAGE.md`
- `RHCSA_EX200_Exam_Simulator/docs/RHCSA_V10_QUESTION_STANDARD.md`
