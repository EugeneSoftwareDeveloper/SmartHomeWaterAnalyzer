# Документация SmartHomeWaterAnalyzer

Эта папка содержит **техническую документацию** для разработчиков и агентов. Если ты пользователь, который просто хочет установить и запустить приложение — иди в [`../README.md`](../README.md).

## Структура

| Документ | Для кого | О чём |
|---|---|---|
| [01-architecture.md](./01-architecture.md) | Разработчик, добавляющий фичу | Слои, зависимости, точки расширения, паттерны |
| [02-ble-protocol.md](./02-ble-protocol.md) | Разработчик BLE-части | GATT-структура BLE-C600, формат кадра FF02, алгоритм декодирования |
| [03-control-commands.md](./03-control-commands.md) | Тот, кто будет искать байты команд | HCI snoop guide, Wireshark, как заполнить commands.dart |
| [04-ui-design.md](./04-ui-design.md) | Разработчик UI | Material 3, цветовые конвенции, виджеты, gauge, layout |

## Перед началом работы

Прочитай в порядке: [`../AGENTS.md`](../AGENTS.md) → этот индекс → нужный документ.

История изменений — в `git log master..` и в issues/PR на GitHub репозитория.

## Связанные внешние документы

- [`SmartHomeService/docs/09-yinmik-ble-water-quality-protocol.md`](https://github.com/EugeneSoftwareDeveloper/SmartHomeService/blob/master/docs/09-yinmik-ble-water-quality-protocol.md) — исследование протокола BLE-C600, ссылки на reverse engineering, открытые реализации (jdeath/BLE-YC01, WaterQualityApp), карта полей.
