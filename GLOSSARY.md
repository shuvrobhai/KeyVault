# KeyVault

KeyVault is a macOS environment switcher. It stores named sets of environment
variables and renders the active set into a shell file that terminal sessions
read on startup.

## Language

**Profile**:
A named set of environment variables. At most one profile is active at a time.
_Avoid_: Environment, context, config, workspace

**Environment Variable**:
A single stored key–value pair belonging to a profile. Not a live variable in a
running process — it is a declaration that becomes one only once a terminal
sources the exports file.
_Avoid_: Setting, export, env var (as a noun for the stored pair)

**Active Profile**:
The one profile whose environment variables are currently rendered into the
exports file, and therefore the one new terminal sessions will use. Selecting a
profile in the sidebar does not make it active; only activation does.
_Avoid_: Selected profile, current profile, enabled profile, default profile

**Activation**:
The act of making a profile the active profile, replacing whichever profile was
previously active. Profiles are never active concurrently.
_Avoid_: Enable, select, switch, apply, load, set

**Exports File**:
The generated shell file at `~/.env-switcher/exports`, containing the active
profile's environment variables as `export` statements. It is the sole interface
between KeyVault and the user's shell.
_Avoid_: Env file, `.env`, output file, env-switcher file

**Source Line**:
The single line a user adds to `~/.zshrc` so that new terminal sessions read the
exports file. Adding it is a one-time, opt-in setup step.
_Avoid_: Integration line, hook, setup line, shell config