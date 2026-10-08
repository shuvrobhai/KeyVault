---
status: accepted
---

# Sandbox disabled so KeyVault can write to the user's home directory

KeyVault's whole job is to render the active profile into
`~/.env-switcher/exports`, a path a new terminal session reads via a line in the
user's `~/.zshrc`. A sandboxed app cannot write to an arbitrary path in the
user's home directory. Rather than relocate the exports file into a container,
we disabled the app sandbox and kept the plain home-directory path.

## Considered Options

- **Sandboxed app + security-scoped bookmark to a user-chosen folder.** Rejected:
  adds a permission prompt on first run, and the shell would need to know the
  granted path anyway — so the `.zshrc` line stops being a constant.
- **Sandboxed app, exports written into a shared container.** Rejected: container
  paths are UUID-prefixed and unstable, so the `.zshrc` line can't hardcode one.
  App groups exist for app↔extension sharing, not for exposing a stable path to
  a shell.
- **Sandboxed app + launch agent that writes the file.** Rejected as
  disproportionate for a three-file utility.

## Consequences

- KeyVault cannot ship on the Mac App Store. Distribution is direct download,
  which means Developer ID signing and notarization are on us.
- `~/.env-switcher/exports` is now a public contract, not an internal detail.
  Every existing user's `.zshrc` hardcodes it. Moving it is a breaking change
  that needs a migration path, not a refactor.
- KeyVault can write anywhere the user can. The app must stay disciplined about
  only ever touching `~/.env-switcher/`.