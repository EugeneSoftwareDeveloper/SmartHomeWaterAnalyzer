"""Выпуск сборки: те же проверки, что в CI, потом запуск релиза.

Зачем. Релиз ставится тегом, а падает через десять минут — и почти
всегда не на сборке, а на мелочи, которую видно локально за пять секунд:
незамеченный `info` от анализатора, забытый `build_runner` после правки
модели, неотформатированный файл, версия в pubspec, разошедшаяся с
тегом. Скрипт прогоняет ТЕ ЖЕ проверки, что `.github/workflows/ci.yml`,
до того как что-то уйдёт на раннер.

Проверки перечислены одним списком GATES ниже. Если меняется ci.yml —
менять надо здесь же, иначе локальная проверка перестанет значить то,
что она обещает.

Два отличия от простого «прогнать команды»:

  * анализатор проверяется не только по коду возврата, но и по тексту —
    `flutter analyze` в некоторых версиях отдаёт ноль при замечаниях, а
    в CI любой `info` роняет сборку;
  * форматирование проверяется с теми же исключениями, что в CI
    (генерируемые файлы), иначе шаг падал бы на выводе build_runner.

Запуск (из корня проекта):
    python tools/ship.py --check          # только проверки
    python tools/ship.py --tag 1.3.0      # проверки + тег + push

Тег и есть публикация: `.github/workflows/release.yml` ловит `v*`,
собирает APK по ABI и создаёт GitHub Release с разделом из CHANGELOG.md.
Поэтому скрипт заранее сверяет три вещи, которые workflow проверить не
может, пока не потратит десять минут: версия в pubspec совпадает с
тегом, раздел в CHANGELOG существует и непустой, рабочее дерево чистое.

Требуется `git`; для `--tag` — доступ на push в origin.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Консоль Windows по умолчанию в cp1251: и стрелки, и кириллица в ней
# либо ломаются, либо роняют скрипт. Печатаем в UTF-8 явно.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

CI = Path(".github/workflows/ci.yml")

# Генерируемое не форматируем и не коммитим отформатированным: CI сначала
# запускает build_runner, а потом проверяет формат, и его собственный
# вывод завалил бы проверку.
GENERATED = ("*.g.dart", "*.freezed.dart")
GENERATED_DIRS = ("lib/l10n/generated",)


def run(cmd: list[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    """Запуск без shell.

    На Windows `flutter`, `dart` и `gh` — это .bat/.cmd, и без shell
    интерпретатор их не находит: subprocess падает с WinError 2. Вместо
    shell=True резолвим полный путь сами — так же работает и на Linux.
    """
    resolved = shutil.which(cmd[0])
    if resolved is None:
        print(f"ОШИБКА: не найдена команда «{cmd[0]}». Она есть в PATH?")
        sys.exit(2)
    return subprocess.run(
        [resolved, *cmd[1:]],
        capture_output=capture,
        text=True,
        encoding="utf-8",
        errors="replace",
        shell=False,
    )


def sources_to_format() -> list[str]:
    """Файлы под проверку формата — с исключениями, как в CI."""
    files: list[str] = []
    for root in ("lib", "test"):
        for path in Path(root).rglob("*.dart"):
            posix = path.as_posix()
            if any(path.match(pattern) for pattern in GENERATED):
                continue
            if any(posix.startswith(d) for d in GENERATED_DIRS):
                continue
            files.append(posix)
    return sorted(files)


def check_flutter_version() -> None:
    """Предупреждает, если локальный Flutter не тот, что в CI.

    Версия в CI запинена (3.41.9). Локально обычно стоит канал stable, и
    он уезжает вперёд: тогда локальный прогон проверяет не то, что
    проверит раннер, а `flutter pub get` может ещё и переписать
    pubspec.lock под более новые пакеты.
    """
    if not CI.exists():
        return
    pinned = re.search(r"flutter-version:\s*([\d.]+)", CI.read_text(encoding="utf-8"))
    if not pinned:
        return
    local = run(["flutter", "--version"], capture=True).stdout or ""
    found = re.search(r"Flutter\s+([\d.]+)", local)
    if found and found[1] != pinned[1]:
        print(
            f"ВНИМАНИЕ: локально Flutter {found[1]}, в CI запинен {pinned[1]}.\n"
            "         Локальный прогон проверяет не то же, что раннер, а\n"
            "         `pub get` может переписать pubspec.lock. Сверьтесь\n"
            "         перед тем, как коммитить lock.\n"
        )


def gates() -> bool:
    """Прогоняет проверки CI. True — всё зелено."""
    steps: list[tuple[str, list[str]]] = [
        ("зависимости", ["flutter", "pub", "get"]),
        ("локализация", ["flutter", "gen-l10n"]),
        (
            "кодогенерация",
            ["dart", "run", "build_runner", "build", "--delete-conflicting-outputs"],
        ),
        (
            "формат",
            ["dart", "format", "--output=none", "--set-exit-if-changed",
             *sources_to_format()],
        ),
        ("анализатор", ["flutter", "analyze"]),
        ("тесты", ["flutter", "test"]),
    ]

    for name, cmd in steps:
        shown = " ".join(cmd[:4]) + (" …" if len(cmd) > 4 else "")
        print(f"→ {name}: {shown}")
        result = run(cmd, capture=True)
        if result.returncode != 0:
            print(f"\nПРОВАЛ на «{name}». Вывод команды:\n")
            print(result.stdout or "")
            print(result.stderr or "")
            return False
        if name == "анализатор" and "No issues found" not in (result.stdout or ""):
            print("\nАнализатор нашёл замечания — в CI это провал:\n")
            print(result.stdout or "")
            return False
        print("  ок")
    return True


def pubspec_version() -> str:
    text = Path("pubspec.yaml").read_text(encoding="utf-8")
    match = re.search(r"^version:\s*([^\s+]+)", text, re.MULTILINE)
    if not match:
        print("ОШИБКА: в pubspec.yaml не нашлась строка version:")
        sys.exit(2)
    return match[1]


def changelog_section(version: str) -> bool:
    """Есть ли в CHANGELOG.md непустой раздел этой версии."""
    path = Path("CHANGELOG.md")
    if not path.exists():
        return False
    lines = path.read_text(encoding="utf-8").splitlines()
    body: list[str] = []
    inside = False
    for line in lines:
        if line.startswith("## ["):
            if inside:
                break
            inside = f"## [{version}]" in line
            continue
        if inside:
            body.append(line)
    return any(line.strip() for line in body)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="только проверки")
    parser.add_argument(
        "--tag",
        metavar="ВЕРСИЯ",
        help="после проверок поставить тег v<ВЕРСИЯ> и запушить его",
    )
    args = parser.parse_args(argv)

    if not Path("pubspec.yaml").exists():
        print("ОШИБКА: запускать из корня проекта.")
        return 2

    check_flutter_version()
    if not gates():
        return 1
    print("\nВсе проверки пройдены.")

    if not args.tag:
        return 0

    version = args.tag.lstrip("v")
    declared = pubspec_version()
    if version != declared:
        print(f"\nВ pubspec.yaml версия {declared}, а тег просится v{version}.")
        print("Workflow сверяет их сам и откажется собирать — поправьте pubspec.")
        return 1

    if not changelog_section(version):
        print(f"\nВ CHANGELOG.md нет непустого раздела «## [{version}]».")
        print("Release возьмёт описание оттуда; без него релиз выйдет пустым.")
        return 1

    dirty = run(["git", "status", "--porcelain"], capture=True).stdout.strip()
    if dirty:
        print("\nЕсть незакоммиченные изменения — тег указал бы не на них.")
        return 1

    tag = f"v{version}"
    created = run(["git", "tag", tag], capture=True)
    if created.returncode != 0:
        print(created.stderr or created.stdout or "")
        return 1
    pushed = run(["git", "push", "origin", tag], capture=True)
    if pushed.returncode != 0:
        print(pushed.stderr or pushed.stdout or "")
        return 1

    print(f"\nТег {tag} создан и запушен — release.yml собирает APK.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
