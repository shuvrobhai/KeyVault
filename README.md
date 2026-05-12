# KeyVault

**Environment switcher for macOS developers.**

KeyVault lets you create **profiles** of environment variables and activate them with a single click.  
When you open a new terminal, your active profile's exports are sourced automatically.

## Features

- Manage multiple sets of environment variables
- Activate a profile to instantly switch contexts
- Variables are written to `~/.env-switcher/exports`
- One‑line `.zshrc` integration (opt‑in)
- Clean native macOS UI built with SwiftUI

## Getting Started

1. Download the latest release (or build from source).
2. Open KeyVault, create a profile, and add variables.
3. Add the following line to your `~/.zshrc`:

   `[ -f ~/.env-switcher/exports ] && source ~/.env-switcher/exports`

4. Activate a profile in the app, then open a new terminal — your env vars are ready!

## Building from Source

- Requires Xcode 16+ and macOS 15+
- Open `KeyVaultApp.xcodeproj` and hit Run
- Sandbox is **disabled** (the app writes directly to your home directory)

## License

MIT – see [LICENSE](LICENSE)
