# Podman and systemd integration

## Exam focus

- Generate or write systemd/Quadlet definitions for persistent containers.
- Use user services for rootless containers and enable lingering where appropriate.
- Validate start, stop, enablement, and reboot persistence.

## Useful starting command

```bash
podman generate systemd --new --files NAME
```

> Practice on a disposable RHCSA VM or snapshot. Verify the result rather than only the command exit status.
