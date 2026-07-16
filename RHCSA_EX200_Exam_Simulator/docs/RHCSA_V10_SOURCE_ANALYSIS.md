# Deep source analysis and simulator gap assessment

## Scope and method

The analysis uses the supplied RH124 RHEL 10 course material, RH134 RHEL 10 course material, the 2026 RHCSA 10 study companion, the official EX200 RHEL 10 objectives, the original simulator question design, and the current v6 question catalog.

Every official objective was mapped to source chapters and to the existing question files. Existing labs were then assessed for: objective relevance, state change versus report-only work, persistence, difficulty spread, self-validation, destructive risk, and exam realism.

## Source integrity

- `Markelov Andrey - Red Hat RHCSA 10 Study Companion (Certification Study Companion Series) - 2026.pdf` — 10,408,989 bytes — SHA-256 `ab0d08ad9984dc3de9516a5a8c01115b36f9b99d7c4d7df0408e444897fea345`
- `RH124(1).docx` — 5,036,683 bytes — SHA-256 `7b9ea8ab03275f51db1fc6502b8acb7c2fc386bf2746534e5e460b4f114cd47a`
- `RH134(1).docx` — 4,774,244 bytes — SHA-256 `642e622494ebeb63f08cfb88c381941c00eec25bbd39c07d30b625a13eac18fd`

## What each source contributes

### RH124 RHEL 10

RH124 is the strongest source for command-line access, local documentation, file management, text editing, redirection, users and groups, standard permissions, RPM and DNF, Flatpak, processes, services, NetworkManager, hostname resolution, and SSH. It defines the foundational tasks that should dominate difficulty levels 1 and 2.

### RH134 RHEL 10

RH134 supplies most of the advanced and persistence-focused material: conditional scripts and loops, regular expressions, at/cron/systemd timers, persistent journaling, SELinux, archives and transfer, TuneD, partitions and LVM, boot targets and boot interruption, superuser recovery, firewalld, NFS, autofs, installation, Podman, and image mode. Its review labs informed the integrated difficulty-5 scenarios.

### RHCSA 10 Study Companion (2026)

The study companion provides an exam-oriented synthesis across command-line tools, scripting, users and groups, storage, file systems, running systems, scheduling and OpenSSH, software management, networking, firewalld, SELinux, and supplementary container and installation material. It is especially useful for cross-topic sequencing and exam-style troubleshooting.

## Original simulator baseline

The original simulator establishes a useful hands-on pattern: explicit task state, prepared resources, optional hints, concrete commands, live checks, and cleanup. Its strongest coverage is in essential tools, with detailed labs for permissions, archives, links, grep, SSH, and local documentation. Later objective chapters in the original catalog were incomplete, so they cannot be used as the sole coverage source.

## Findings in the v6 catalog

v6 had good numerical balance—45 labs per chapter and difficulty labels 1 through 5—but numerical balance was not the same as exam coverage. Several higher-level labs only saved command inventories or reports. The weakest areas were boot recovery, target switching, service lifecycle, assigning PVs to VGs, persistent journals, package transactions, Flatpak transactions, storage growth, NFS/autofs, and persistent network/security configuration.

Objectives with no state-changing lab in the pre-v7 heuristic audit: **8**.

- 1.5 — Log in and switch users in multiuser targets
- 4.3 — Interrupt the boot process to gain access to a system
- 7.1 — Schedule tasks using at, cron, and systemd timer units
- 7.2 — Start and stop services and configure them to start at boot
- 7.3 — Configure systems to boot into a specific target automatically
- 7.4 — Configure time service clients
- 7.5 — Install and update packages from CDN, remote repositories, or local files
- 7.6 — Modify the system bootloader

Objectives where report-only labs outnumbered state-changing labs: **37**.

- 1.2 — Use input-output redirection (>, >>, |, 2>, etc.) (10 report-only vs 3 state-changing)
- 1.5 — Log in and switch users in multiuser targets (9 report-only vs 0 state-changing)
- 1.6 — Archive, compress, unpack, and uncompress files using tar, gzip, and bzip2 (10 report-only vs 3 state-changing)
- 1.7 — Create and edit text files (10 report-only vs 3 state-changing)
- 2.1 — Configure access to RPM repositories (25 report-only vs 2 state-changing)
- 2.2 — Install and remove RPM software packages (19 report-only vs 9 state-changing)
- 2.3 — Configure access to Flatpak repositories (13 report-only vs 1 state-changing)
- 2.4 — Install and remove Flatpak software packages (6 report-only vs 1 state-changing)
- 4.1 — Boot, reboot, and shut down a system normally (4 report-only vs 1 state-changing)
- 4.2 — Boot systems into different targets manually (4 report-only vs 1 state-changing)
- 4.4 — Identify CPU/memory intensive processes and kill processes (15 report-only vs 9 state-changing)
- 4.5 — Adjust process scheduling (12 report-only vs 1 state-changing)
- 4.6 — Manage tuning profiles (12 report-only vs 1 state-changing)
- 4.7 — Locate and interpret system log files and journals (12 report-only vs 1 state-changing)
- 4.8 — Preserve system journals (4 report-only vs 1 state-changing)
- 4.9 — Start, stop, and check the status of network services (20 report-only vs 1 state-changing)
- 4.10 — Securely transfer files between systems (4 report-only vs 1 state-changing)
- 5.1 — List, create, and delete partitions on GPT disks (12 report-only vs 10 state-changing)
- 5.2 — Create and remove physical volumes (5 report-only vs 2 state-changing)
- 5.3 — Assign physical volumes to volume groups (4 report-only vs 3 state-changing)
- 5.4 — Create and delete logical volumes (4 report-only vs 2 state-changing)
- 6.1 — Create, mount, unmount, and use VFAT, ext4, and XFS file systems (24 report-only vs 9 state-changing)
- 6.2 — Mount and unmount NFS network file systems (21 report-only vs 1 state-changing)
- 6.3 — Configure autofs (12 report-only vs 1 state-changing)
- 6.4 — Extend existing logical volumes (4 report-only vs 1 state-changing)
- 6.5 — Diagnose and correct file permission problems (4 report-only vs 1 state-changing)
- 7.1 — Schedule tasks using at, cron, and systemd timer units (45 report-only vs 0 state-changing)
- 7.2 — Start and stop services and configure them to start at boot (6 report-only vs 0 state-changing)
- 7.3 — Configure systems to boot into a specific target automatically (6 report-only vs 0 state-changing)
- 7.4 — Configure time service clients (13 report-only vs 0 state-changing)
- 7.5 — Install and update packages from CDN, remote repositories, or local files (5 report-only vs 0 state-changing)
- 7.6 — Modify the system bootloader (13 report-only vs 0 state-changing)
- 8.1 — Configure IPv4 and IPv6 addresses (23 report-only vs 3 state-changing)
- 8.2 — Configure hostname resolution (13 report-only vs 1 state-changing)
- 8.3 — Configure network services to start automatically at boot (15 report-only vs 3 state-changing)
- 8.4 — Restrict network access using firewalld and firewall-cmd (13 report-only vs 1 state-changing)
- 10.1 — Configure firewall settings using firewall-cmd and firewalld (9 report-only vs 5 state-changing)

Objectives not reliably identified by the old filename/tag classifier: **10**.

- 1.1 — Access a shell prompt and issue commands with correct syntax
- 1.5 — Log in and switch users in multiuser targets
- 1.7 — Create and edit text files
- 1.8 — Create, delete, copy, and move files and directories
- 3.2 — Use looping constructs to process file or command-line input
- 4.1 — Boot, reboot, and shut down a system normally
- 4.2 — Boot systems into different targets manually
- 4.3 — Interrupt the boot process to gain access to a system
- 4.9 — Start, stop, and check the status of network services
- 5.3 — Assign physical volumes to volume groups

## v7 design decisions

- Preserve the working installer, update mechanism, Web UI, and terminal-service architecture.
- Treat chapters 1–10 as the official EX200 core and chapters 11–12 as supplementary content.
- Add a machine-readable 62-objective RHEL 10 manifest.
- Add objective IDs, lab kind, state-change classification, and persistence classification to every core lab.
- Keep existing drills, but shorten their question stems and remove complete commands from hints.
- Add one dedicated exam-grade lab for every official objective.
- Add extra difficulty-1 and difficulty-3 labs for objectives that had no reliable coverage.
- Add one integrated difficulty-5 scenario per core chapter.
- Use real system state where safe; use guided-manual labs for reboot and GRUB recovery.
- Require at least three labs, three difficulty levels, one exam-grade lab, and one state-changing lab per objective, except the guided boot-recovery objective.
- Require persistence coverage where the objective explicitly concerns reboot survival or service enablement.

## Question-writing standard

Questions describe the required end state and all necessary identifiers, but not the solution sequence. Hints name a concept, command family, or verification method; they do not contain the complete reference command. Exact commands remain available only through the existing optional command-reveal mechanism.

## Result

- Official objectives: **62**
- Objectives passing policy: **62**
- Core labs: **542**
- Supplementary labs: **90**
- Total labs: **632**
- Total tasks: **1255**
- Question-quality errors: **0**
- Average question length: **96.0 characters**
- Average hint length: **57.3 characters**

## Runtime caveat

Static and source-level validation cannot prove that every external repository, Flatpak remote, NFS service, or optional RHEL package is available on a particular practice VM. Labs that require repository access or a reboot state this explicitly and are isolated from the simulator terminal dependency. No active exercise installs, removes, or modifies tmux.
