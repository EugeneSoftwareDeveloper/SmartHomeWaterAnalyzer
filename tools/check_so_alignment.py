"""Проверка выравнивания нативных библиотек на 16 KB.

Google Play требует, чтобы приложения, таргетящие Android 15+, работали на
устройствах с размером страницы памяти 16 KB. Практически это значит, что у
каждой 64-битной `.so` сегменты `PT_LOAD` должны быть выровнены минимум на
`0x4000`. Проверка нужна именно в CI: локально ничего не падает, а нарушение
всплывает только при заливке в Play Console — то есть в самый неудобный момент.

Выравнивание даёт не наш код, а тулчейн: NDK r28+ выравнивает на 16 KB по
умолчанию. Поэтому регрессия молчаливая — она приезжает с обновлением
зависимости или NDK, и заметить её без такой проверки нечем.

32-битные ABI (`armeabi-v7a`, `x86`) под требование не подпадают: 16 KB —
свойство 64-битных устройств. Они выводятся в отчёт, но не влияют на вердикт.

Зависимостей нет — только стандартная библиотека, чтобы шаг CI не требовал
установки пакетов.

Запуск:
    python tools/check_so_alignment.py build/app/outputs/bundle/release/app-release.aab
    python tools/check_so_alignment.py build/app/outputs/flutter-apk/app-release.apk

Проверяется **минимальное** выравнивание среди сегментов `PT_LOAD` библиотеки:
требование обязано выполняться для каждого сегмента, а не для лучшего из них.

Код возврата: 0 — всё выровнено, 1 — есть нарушения или во входном файле не
нашлось ни одной `.so`, 2 — файл не читается.
"""

from __future__ import annotations

import struct
import sys
import zipfile

# Минимально допустимое выравнивание сегмента PT_LOAD.
MIN_ALIGN = 0x4000  # 16 KB

# ABI, для которых требование не действует.
ABI_32BIT = frozenset({"armeabi-v7a", "x86"})

PT_LOAD = 1


def _load_aligns(data: bytes) -> list[int]:
    """Возвращает p_align всех сегментов PT_LOAD из ELF-образа."""
    if data[:4] != b"\x7fELF":
        return []

    is_64 = data[4] == 2
    endian = "<" if data[5] == 1 else ">"

    if is_64:
        ph_off = struct.unpack_from(endian + "Q", data, 0x20)[0]
        ph_entsize = struct.unpack_from(endian + "H", data, 0x36)[0]
        ph_num = struct.unpack_from(endian + "H", data, 0x38)[0]
        align_off = 0x30
        align_fmt = endian + "Q"
    else:
        ph_off = struct.unpack_from(endian + "I", data, 0x1C)[0]
        ph_entsize = struct.unpack_from(endian + "H", data, 0x2A)[0]
        ph_num = struct.unpack_from(endian + "H", data, 0x2C)[0]
        align_off = 0x1C
        align_fmt = endian + "I"

    aligns = []
    for i in range(ph_num):
        entry = ph_off + i * ph_entsize
        if struct.unpack_from(endian + "I", data, entry)[0] != PT_LOAD:
            continue
        aligns.append(struct.unpack_from(align_fmt, data, entry + align_off)[0])
    return aligns


def _abi_of(name: str) -> str:
    """Достаёт ABI из пути внутри архива.

    APK хранит библиотеки как `lib/<abi>/x.so`, AAB — как `base/lib/<abi>/x.so`.
    """
    parts = name.split("/")
    if "lib" in parts:
        idx = parts.index("lib")
        if idx + 1 < len(parts):
            return parts[idx + 1]
    return "?"


def check(archive_path: str) -> int:
    failures: list[str] = []
    checked = 0
    required = 0

    with zipfile.ZipFile(archive_path) as archive:
        names = sorted(n for n in archive.namelist() if n.endswith(".so"))
        for name in names:
            try:
                aligns = _load_aligns(archive.read(name))
            except (struct.error, IndexError) as err:
                # Битый или неожиданно устроенный ELF — это тоже провал
                # проверки, а не повод промолчать.
                print(f"ПЛОХО {name}: не удалось разобрать ELF ({err})")
                failures.append(name)
                checked += 1
                required += 1
                continue

            if not aligns:
                print(f"ПЛОХО {name}: не найдено ни одного сегмента PT_LOAD")
                failures.append(name)
                checked += 1
                required += 1
                continue

            checked += 1
            # Именно min: требование обязано выполняться для КАЖДОГО
            # сегмента PT_LOAD. При max библиотека, у которой один сегмент
            # выровнен на 64 KB, а другой на 4 KB, прошла бы проверку.
            align = min(aligns)
            abi = _abi_of(name)
            exempt = abi in ABI_32BIT
            ok = exempt or align >= MIN_ALIGN
            if not exempt:
                required += 1
            if not ok:
                failures.append(name)

            mark = "  ok " if ok else "ПЛОХО"
            note = "  (32-бит, не требуется)" if exempt else ""
            short = name.split("/")[-1]
            print(
                f"{mark} {abi:12s} {short:32s} "
                f"p_align=0x{align:<7x} {align // 1024:>3d} KB{note}"
            )

    if checked == 0:
        print(f"\nОШИБКА: в {archive_path} не найдено ни одной .so — проверять нечего.")
        return 1

    print(
        f"\nвсего .so: {checked} | под требование Play: {required} | "
        f"не выровнено: {len(failures)}"
    )

    if failures:
        print(
            "\nЭти библиотеки не выровнены на 16 KB — Play отклонит сборку.\n"
            "Скорее всего, дело в обновлении зависимости с нативным кодом или NDK:\n"
            "  " + "\n  ".join(failures)
        )
        return 1

    print("Все 64-битные библиотеки выровнены на 16 KB.")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(__doc__)
        print("Укажите путь к .apk или .aab одним аргументом.")
        return 2
    try:
        return check(argv[1])
    except FileNotFoundError:
        print(f"ОШИБКА: файл не найден — {argv[1]}")
        return 2
    except zipfile.BadZipFile:
        print(f"ОШИБКА: {argv[1]} не похож на apk/aab (не zip-архив).")
        return 2
    except (struct.error, IndexError) as err:
        print(f"ОШИБКА: не удалось разобрать содержимое {argv[1]}: {err}")
        return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
