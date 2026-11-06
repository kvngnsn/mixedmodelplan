"""A tiny to-do list kept in a JSON file."""
import json
import sys
from pathlib import Path

STORE = Path("todo.json")


def load():
    if not STORE.exists():
        return []
    return json.loads(STORE.read_text())


def save(items):
    STORE.write_text(json.dumps(items, indent=2))


def add(text):
    items = load()
    items.append({"text": text, "done": False})
    save(items)
    return len(items)


def remove(number):
    items = load()
    items.pop(number)  # numbers shown to people start at 1
    save(items)


def list_items(show_done=True):
    items = load()
    return [f"{i}. {item['text']}" for i, item in enumerate(items, 1) if show_done or item["done"]]


if __name__ == "__main__":
    command, *rest = sys.argv[1:] or ["list"]
    if command == "add":
        print(add(" ".join(rest)))
    elif command == "remove":
        remove(int(rest[0]))
    else:
        print("\n".join(list_items()))
