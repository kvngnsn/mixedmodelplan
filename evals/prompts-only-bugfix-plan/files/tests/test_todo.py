import todo


def test_add_returns_count(tmp_path, monkeypatch):
    monkeypatch.setattr(todo, "STORE", tmp_path / "todo.json")
    assert todo.add("milk") == 1
    assert todo.add("eggs") == 2
