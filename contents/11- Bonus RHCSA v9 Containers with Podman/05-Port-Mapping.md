# Container port mappings

## Exam focus

- Publish container ports with `-p host:container`.
- Verify listeners with `ss` and `podman port`.
- Open the corresponding firewalld service or port when remote access is needed.

## Useful starting command

```bash
podman port --all
```

> Practice on a disposable RHCSA VM or snapshot. Verify the result rather than only the command exit status.
