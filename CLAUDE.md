# CLAUDE.md

## Project
video-duration.yazi — a plugin for the Yazi terminal file manager to display the total duration of selected video files

Plugin type: [functional / previewer / preloader / fetcher / spotter] — see Yazi plugin docs for what this implies.

## Repository layout
- `main.lua` — plugin entry point; returns a table with the interface methods (`entry`, `peek`, `seek`, `preload`, `setup`, etc.)
- `README.md` — user-facing install + config docs
- `LICENSE`
- (add: `assets/`, `lua/` submodules, etc., if present)

## Yazi plugin model — read before editing main.lua
Yazi runs Lua in two contexts and the rules differ:
- **Sync context**: shared, persistent state across the app. Has full access to `cx` (e.g. `cx.active.current.hovered`). Used by `setup`, by `seek`, and by any plugin annotated with `--- @sync entry` at the top of `main.lua`. Must not block — no `io.open`, no `os.execute`.
- **Async context** (default for `entry`, `peek`, `preload`, `fetch`): isolated per-call, runs concurrently with the UI. Cannot touch `cx` directly. To read app state from async, wrap it in a top-level `ya.sync(function(state, ...) ... end)` — `ya.sync()` calls **must** be at the top level of the file, never inside conditionals.
- Use `ya.async()` to spawn non-blocking work from a sync context when needed.

State persistence pattern (per Yazi docs):
```lua
return {
  setup = function(state, opts)
    state.key1 = opts.key1   -- store config in plugin's isolated state
  end,
  entry = function(state, job)
    -- use state.key1 here
  end,
}
```

## Conventions for this plugin
- Lua version: 5.5 (Yazi's runtime)
- Style: 2-space indent, `snake_case` for locals, `kebab-case` for plugin/entry names
- Error handling: prefer returning `(result, err)` tuples like Yazi's built-ins; surface user-visible errors with `ya.notify({ title = "...", content = "...", level = "error" })`
- Logging: `ya.dbg()` for development, `ya.err()` for real errors. Logs go to Yazi's state dir.
- Never use globals; always `local`.

## Common tasks
- Test locally: symlink this repo into `~/.config/yazi/plugins/[plugin-name].yazi`, then run `yazi` and exercise the plugin
- Tail logs: `tail -f ~/.local/state/yazi/yazi.log` (Linux) or the platform-equivalent path
- Lint: [add command if you use selene/luacheck, otherwise delete this line]
- Type-check: relies on `types.yazi`; ensure `.luarc.json` points at the local types plugin path

## What NOT to do
- Don't call `cx.*` from `peek`, `preload`, `fetch`, or any non-`@sync` `entry` — use a `ya.sync()` block instead
- Don't put `ya.sync()` calls inside `if` blocks or function bodies — top level only
- Don't add `print()` or `io.write()` — they break Yazi's TUI; use `ya.dbg`/`ya.notify`
- Don't bump the Yazi version requirement in README without testing on the current Yazi release

## References (consult when needed, don't paraphrase from memory)
- Plugin overview: https://yazi-rs.github.io/docs/plugins/overview/
- Plugin utils API: https://yazi-rs.github.io/docs/plugins/utils/
- Type definitions: `~/.config/yazi/plugins/types.yazi/` (installed via `ya pkg add yazi-rs/plugins:types`)
- Reference implementations: https://github.com/yazi-rs/plugins
