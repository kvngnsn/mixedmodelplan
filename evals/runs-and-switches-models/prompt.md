---
tags: [mixedmodelplan]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

mixedmodelplan this and run it, it's tiny so keep effort low: first haiku lists every function in src/ with its line number into an inventory, then sonnet writes docs/functions.md (one line per function saying what it does) from that inventory. no commits.

Input files: issues.md, src/todo.py, tests/test_todo.py, pytest.ini, private/notes.md
