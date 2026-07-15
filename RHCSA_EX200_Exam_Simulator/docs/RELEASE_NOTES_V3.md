# RHCSA Simulator v3 release notes

## Source of truth

- Repository: `ytra-redhat/RHCSA.github.io`
- Branch: `main`
- Questions: numeric, non-empty directories under `RHCSA_EX200_Exam_Simulator/questions/`
- Progress key: stable `LAB_ID`

## Implemented

- Complete branch archive installation from the configured fork.
- Remote chapter discovery before download and archive-to-API reconciliation.
- Dynamic chapter discovery in installer, CLI and Web UI.
- Twelve chapters and 540 supplied labs are processed.
- Shared persistent progress for CLI and Web UI.
- Legacy filename/path progress migration to `LAB_ID`.
- Robust quoted and multiline question/hint/command parsing.
- No-cache Web UI progress rendering.
- Atomic installation, progress preservation and rollback.
- Hourly update timer using the same repository and branch.
- Release-blocking scans for static ten-chapter logic, invalid labs, duplicate IDs,
  forbidden `tmux` question references and GitHub sources outside the configured fork.

## Not changed without approval

Potential content-quality improvements are documented in the delivery report and
have not been applied to the supplied question set.
