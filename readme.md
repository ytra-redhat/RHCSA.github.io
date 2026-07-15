# RHCSA EX200 Exam Simulator

This fork contains the RHCSA v10 simulator and the additional RHCSA v9 bonus chapters.

## Repository source

Installation, reinstallation, questions and updates use only:

```text
https://github.com/ytra-redhat/RHCSA.github.io
```

Branch:

```text
main
```

## Installation from a copied checkout

```bash
sudo ./Install_RHCSA_EX200_Exam_Simulator.sh
```

The installer first discovers all numeric question chapters in the configured fork, downloads the complete `main` branch archive, validates it and then atomically replaces the installed simulator.

## One-line bootstrap

```bash
tmp=$(mktemp -d)
curl -fsSL https://github.com/ytra-redhat/RHCSA.github.io/archive/refs/heads/main.tar.gz |
  tar -xz -C "$tmp"
sudo "$tmp/RHCSA.github.io-main/Install_RHCSA_EX200_Exam_Simulator.sh"
rm -rf "$tmp"
```

## Validation

```bash
python3 RHCSA_EX200_Exam_Simulator/scripts/validate_release.py .
```
