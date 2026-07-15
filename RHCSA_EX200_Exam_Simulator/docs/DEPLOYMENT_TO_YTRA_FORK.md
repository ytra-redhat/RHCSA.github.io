# Deployment to ytra-redhat/RHCSA.github.io

The installer and updater deliberately install the complete `main` branch from:

```text
https://github.com/ytra-redhat/RHCSA.github.io
```

This means the corrected release must first be committed and pushed to the
`main` branch of that repository. Running the installer from a locally copied
working tree does **not** install that local tree; it validates the configured
remote repository and installs its complete branch archive.

## Publish the release

From a local clone of the fork:

```bash
git checkout main
git pull --ff-only origin main
rsync -a --delete /path/to/delivered/RHCSA.github.io/ ./
git status
git add -A
git commit -m "Rework RHCSA simulator installer, dynamic chapters and progress"
git push origin main
```

Review `git status` and `git diff --cached` before committing.

## Install on the VM

From a copied checkout:

```bash
sudo ./Install_RHCSA_EX200_Exam_Simulator.sh --force
```

Or bootstrap directly from the fork:

```bash
tmp=$(mktemp -d)
curl -fsSL https://github.com/ytra-redhat/RHCSA.github.io/archive/refs/heads/main.tar.gz \
  | tar -xz -C "$tmp"
sudo "$tmp/RHCSA.github.io-main/Install_RHCSA_EX200_Exam_Simulator.sh" --force
rm -rf "$tmp"
```

## Validate before publishing

```bash
python3 RHCSA_EX200_Exam_Simulator/scripts/validate_release.py .
RHCSA_EX200_Exam_Simulator/rhcsa --list-objectives
```

The expected result for this release is 12 chapters and 540 labs.
