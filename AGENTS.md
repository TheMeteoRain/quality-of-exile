# Agent Guidelines

## Comments

Comments state facts, not history. Do not write about what the code was, what it used to do, or what it will become. Describe what is, concisely.

- Bad: `; This used to use exe name but now checks the path`
- Bad: `; TODO: will add PoE2 support later`
- Good: `; PoE1 vs PoE2 disambiguated by install folder, not exe name.`

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0):

```
<type>[optional scope]: <description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

- `feat: allow opening settings via context menu outside the game`
- `fix(game): detect PoE1 vs PoE2 by install path`

No AI attribution. Do not add `Co-Authored-By` trailers, "Generated with" lines, or any mention of AI assistants in commits, PRs, or code. Commits read as the human author's own work.
