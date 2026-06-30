# Agent Guidelines

## 1. Core Behavioral Rules (HARD RULES)

### Communication Standards
- MUST NOT use excessive affirmation or compliments (e.g., "You're absolutely right")
- Responses MUST be concise and direct
- MUST critique flawed ideas when necessary
- MUST ask clarifying questions if accuracy is uncertain

### Work Approach
- Do NOT generate multiple script variations; iterate on the same file with git commits
- Do NOT be lazy with data requirements (if 500 items requested, deliver 500, not 10)
- Do NOT change `README.md`; use `README_CC.md` instead

### Emoji Policy
Emojis MUST NOT appear in:
- Code (including comments)
- Commit messages
- Documentation

---

## 2. Code Quality Standards

### Comment Policy (HARD RULE)

**MUST NOT add comments that describe changes:**
- Examples: `removed`, `legacy`, `cleanup`, `hotfix`, `flag removed`, `temporary workaround`

**Comments MUST only explain:**
- Non-obvious logic
- Long-term external invariants
- Maximum 2 lines

```
// Forbidden
// shouldShowDoneButton removed; UI reacts to selection
// legacy code kept for now

// Allowed
// Bound must be >= 30px to render handles reliably
// Server returns seconds (not ms); convert before diffing
```

**Rationale Placement:**
- Change reasoning goes in: planning messages, final responses, PR descriptions
- Change reasoning MUST NOT appear in code comments

### Code Cleanliness
- Remove: dead code, unused imports, debug prints, unnecessary empty lines
- Keep diffs minimal and tightly scoped
- Prefer existing mechanisms over introducing new ones
- Remove all temporary scaffolding before finalizing
- Do NOT add comments explaining code removal
- Do NOT leave unused utilities or files

---

## 3. Development Workflow

### Project Exploration
- MUST explore entire project structure before starting work
- No file may be skipped
- MUST read file contents before modifying

### Ambiguity Handling
- If request is ambiguous, MUST ask for clarification first
- Clarification MUST include concrete options

### Failure Handling
After 3 failed attempts:
1. Stop
2. Record what failed
3. Identify core cause
4. Continue with corrected approach

### Temporary Files
- Place temporary scripts/files under `./tmp/xxx` with proper structure
- Example: videos in `./tmp/videos/xxx`
- Only final versions remain in main project tree

### Legacy Code
- MUST NOT leave legacy, deprecated, or unused code
- All obsolete code MUST be removed

---

## 4. Environment & Tools

### Python Environment
- All Python projects MUST use `uv` for virtual environments
- System `python` or `python3` MUST NOT be used
- All dependencies via `uv pip install`
- New environments SHOULD use Python 3.11+

### Package Management
- System packages via `brew`
- Python environments via `uv`

### Tool Usage
- MUST check unfamiliar commands using `--help` or `-help` first

---

## 5. Version Control

### Repository Setup
- For non-trivial tasks, MUST initialize Git repository if none exists
- Work MUST be done in local branch named `local_dev_cc`

### Commit Standards
- Important changes MUST be committed incrementally
- Commit format: `(feat|fix|perf|doc|chore): Capitalized message`
- Use clear, scoped messages

---

## 6. Communication & Documentation

### Response Formatting
- Nested bullet lists SHOULD use different bullet characters
- Options and confirmations SHOULD use numbered lists
- Prompt users for compact replies (e.g., `1Y 2N 3C`)
- Multi-step plans SHOULD default to numbered lists

---

## 7. Language-Specific Style Guides

### Python
See [PYTHON_STYLE.md](./PYTHON_STYLE.md) for comprehensive Python coding standards:
- PEP8 compliant, Python 3.11+ typing conventions
- Hanging indent only for continuation lines
- Google style docstrings
- Type hints required for all function signatures
- Use `ruff` for linting and formatting
- For `requirements.txt` or `pyproject.toml`, always use fixed versions (e.g., `package==1.2.3`), never ranges (e.g., `package>=1.2.3`)
