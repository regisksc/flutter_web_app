# hooks: rules

- Hooks enforce gates. Do not weaken, skip, or bypass a gate to get a pass.
- Keep hook scripts short and POSIX-friendly. Test with tool/test_hooks.sh.
- A hook never commits, stages, or pushes. The human commits.
- Changing a hook is a scope change: name it in the spec or ask first.
- Log only what a human needs. Never print secrets.
