# Container troubleshooting

## Exam focus

- Use `podman logs`, `podman inspect`, and `podman events`.
- Check image availability, port conflicts, permissions, SELinux, and storage.
- Reproduce the failure with an explicit command and verify the exit status.

## Useful starting command

```bash
podman logs NAME
```

> Practice on a disposable RHCSA VM or snapshot. Verify the result rather than only the command exit status.
