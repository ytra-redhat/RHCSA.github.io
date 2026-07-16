# Legacy storage and installation planning

## Exam focus

- Interpret existing partitions, filesystems, LVM, swap, and mount configuration.
- Plan destructive changes before executing them.
- Use UUIDs or labels for persistent mounts and verify `/etc/fstab` safely.

## Useful starting command

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
```

> Practice on a disposable RHCSA VM or snapshot. Verify the result rather than only the command exit status.
