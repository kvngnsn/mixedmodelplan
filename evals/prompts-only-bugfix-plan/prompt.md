---
tags: [mixedmodelplan]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

there are 3 bugs in issues.md for this little python todo cli. use mixedmodelplan but just write the prompts, i'll run each phase in its own terminal. one model should find the causes and write failing tests, a different one should fix them. rules: never commit the private/ folder, and run `python -m pytest` before any commit. don't push anything.

Input files: issues.md, src/todo.py, tests/test_todo.py, pytest.ini, private/notes.md
