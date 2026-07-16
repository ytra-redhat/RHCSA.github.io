# Cockpit

## Exam focus

- Enable the Cockpit socket and verify port 9090.
- Use Cockpit as an administration interface, not as a substitute for CLI knowledge.
- Confirm firewalld and SELinux allow the intended access.

## Useful starting command

```bash
systemctl enable --now cockpit.socket
```

> Practice on a disposable RHCSA VM or snapshot. Verify the result rather than only the command exit status.
