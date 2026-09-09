import '../quality/profile.dart';
import 'parameter_help.dart';

/// Содержимое справки на русском.
///
/// Хранится структурой на Dart, а не ключами в ARB, потому что это не подписи
/// интерфейса, а связный справочный текст: у каждой градации есть числовая
/// граница, цвет и пояснение, и разорвать их на две сотни отдельных ключей
/// значило бы сделать и текст, и код нечитаемыми. Соответствие языков
/// проверяется тестом: он сверяет, что у обоих наборов совпадают параметры,
/// разделы, границы диапазонов и цвета.
abstract final class RussianParameterHelp {
  static ParameterHelp byKey(String key, NormsProfile profile) {
    return switch (key) {
      'ph' => _ph(profile),
      'orp' => _orp(profile),
      'ec' => _ec(profile),
      'tds' => _tds(profile),
      'salinity' => _salinity(profile),
      'temperature' => _temperature(profile),
      'sg' => _sg(profile),
      _ => throw ArgumentError('Unknown parameter: $key'),
    };
  }

  static ParameterHelp _ph(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.pool => const [
        HelpRange(
          label: 'Сильно кислая',
          range: '< 6.8',
          note: 'Раздражает кожу и глаза, разрушает дезинфицирующие вещества',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Кислая',
          range: '6.8 – 7.2',
          note: 'Снижает эффективность хлора, требует подщелачивания',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Идеальная',
          range: '7.2 – 7.6',
          note: 'Максимальная эффективность дезинфекции, нейтральная для кожи',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Приемлемая',
          range: '7.6 – 7.8',
          note: 'Допустимо, но хлор работает уже хуже',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Высокая',
          range: '7.8 – 8.4',
          note: 'Помутнение, отложения солей, потеря эффективности хлора',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Сильно щелочная',
          range: '> 8.4',
          note: 'Срочное подкисление, известковый налёт неизбежен',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.aquariumFresh => const [
        HelpRange(
          label: 'Опасно кислая',
          range: '< 5.5',
          note: 'Стресс и гибель большинства рыб',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Кислая',
          range: '5.5 – 6.5',
          note: 'Подходит дискусам, неонам, некоторым тетрам',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Слабокислая',
          range: '6.5 – 7.0',
          note: 'Большинство тропических пресноводных видов',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Нейтральная',
          range: '7.0 – 7.5',
          note: 'Универсальный диапазон, оптимум для большинства',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Слабощелочная',
          range: '7.5 – 8.2',
          note: 'Цихлиды Малави и Танганьики, гуппи, моллинезии',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Щелочная',
          range: '8.2 – 9.0',
          note: 'Только специализированные виды',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Опасно щелочная',
          range: '> 9.0',
          note: 'Аммиак становится токсичным, требуется срочное вмешательство',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.hydroponics => const [
        HelpRange(
          label: 'Опасно кислая',
          range: '< 4.5',
          note: 'Корни повреждаются, поглощение питания нарушено',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Кислая',
          range: '4.5 – 5.5',
          note: 'Подходит чернике, азалии, некоторым цветам',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Норма',
          range: '5.5 – 5.8',
          note: 'Доступность железа, марганца, цинка повышенная',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Оптимум',
          range: '5.8 – 6.5',
          note: 'Универсальный для большинства культур: помидоры, огурцы, салат',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Норма',
          range: '6.5 – 7.0',
          note: 'Подходит для большинства, но железо и марганец менее доступны',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Высокая',
          range: '7.0 – 8.0',
          note: 'Дефицит микроэлементов, нужна коррекция кислотой',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Опасно щелочная',
          range: '> 8.0',
          note: 'Питание не усваивается, выпадение солей в осадок',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.drinking => const [
        HelpRange(
          label: 'Сильно кислая',
          range: '< 4.5',
          note: 'Разрушает зубную эмаль и слизистую желудка',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Кислая',
          range: '4.5 – 6.0',
          note: 'Постоянное употребление нежелательно',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Слабокислая',
          range: '6.0 – 6.5',
          note: 'Допустимо, ВОЗ не рекомендует ниже 6.5',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Норма',
          range: '6.5 – 7.2',
          note: 'Близко к нейтральной, безопасно для постоянного питья',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Идеальная',
          range: '7.2 – 7.8',
          note: 'Соответствует pH крови (7.4), наиболее физиологична',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Норма',
          range: '7.8 – 8.5',
          note: 'Верхняя граница рекомендации ВОЗ',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Слабощелочная',
          range: '8.5 – 9.5',
          note: 'Минеральная вода, длительно нежелательно',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Щелочная',
          range: '9.5 – 10.5',
          note: 'Может вызывать раздражение, неприятный мыльный вкус',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Сильно щелочная',
          range: '> 10.5',
          note: 'Опасно для пищеварения',
          color: HelpPalette.dangerDark,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'ph',
      title: 'Кислотность (pH)',
      summary:
          'Показывает, кислая вода, нейтральная или щелочная. '
          'Шкала от 0 (концентрированная кислота) до 14 (концентрированная щёлочь). '
          'Нейтральная вода — 7.0.',
      sections: [
        HelpSection(
          title: 'Зачем нужно',
          text: profile == NormsProfile.drinking
              ? 'Слишком кислая или щелочная вода влияет на пищеварение, разрушает зубную эмаль, '
                    'усиливает коррозию труб (металлический привкус). Норма по ВОЗ для питьевой '
                    'воды — 6.5–8.5.'
              : 'pH влияет на доступность ионов и активность химических процессов. Каждый сценарий '
                    'имеет свой оптимум.',
        ),
        HelpSection(title: 'Тонкая градация', ranges: ranges),
        const HelpSection(
          title: 'Заметка',
          text:
              'pH может слегка плавать между измерениями — это нормально, электрод '
              'стабилизируется во времени. Для точной оценки делай 2-3 замера подряд.',
        ),
      ],
    );
  }

  static ParameterHelp _orp(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.pool => const [
        HelpRange(
          label: 'Опасно низкий',
          range: '< 600 мВ',
          note: 'Дезинфекция неэффективна, риск бактерий и водорослей',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Маловато',
          range: '600 – 650 мВ',
          note: 'Хлора недостаточно, требуется подкорректировать',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Идеальный',
          range: '650 – 750 мВ',
          note: 'Уровень рекомендованный ВОЗ для безопасной воды',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Высокий',
          range: '750 – 850 мВ',
          note: 'Сильное хлорирование, безопасно но раздражает кожу',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Слишком высокий',
          range: '> 850 мВ',
          note: 'Передозировка дезинфектанта, проверь уровень хлора',
          color: HelpPalette.caution,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Сильно восстановительная',
          range: '< −100 мВ',
          note: 'Антиоксидантная среда, характерна для талой и родниковой воды',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Нейтральная',
          range: '−100 – 200 мВ',
          note: 'Без выраженных свойств',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Идеальный',
          range: '200 – 400 мВ',
          note: 'Типичный диапазон чистой питьевой воды',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Норма',
          range: '400 – 600 мВ',
          note: 'Слегка окислительная, безопасна',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Окислительная',
          range: '600 – 800 мВ',
          note: 'Хлорированная водопроводная вода',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Сильно окислительная',
          range: '> 800 мВ',
          note: 'Активное обеззараживание, постоянное питьё нежелательно',
          color: HelpPalette.caution,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'orp',
      title: 'Редокс-потенциал (ORP)',
      summary:
          'Измеряет окислительные/восстановительные свойства воды. Положительные значения '
          'характерны для воды, способной окислять (хлор, кислород), отрицательные — для воды '
          'с антиоксидантными свойствами.',
      sections: [
        HelpSection(
          title: 'Зачем нужно',
          text: profile == NormsProfile.pool
              ? 'Для бассейнов ORP — главный показатель эффективности дезинфекции. ВОЗ '
                    'рекомендует ≥650 мВ — при этом уровне бактерии гибнут за секунды.'
              : 'Связан с присутствием хлора, озона, кислорода. Чистая родниковая вода имеет '
                    'низкий ORP (антиоксидант), хлорированная водопроводная — высокий.',
        ),
        HelpSection(title: 'Тонкая градация', ranges: ranges),
      ],
    );
  }

  static ParameterHelp _ec(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.hydroponics => const [
        HelpRange(
          label: 'Слабая',
          range: '< 500 мкСм/см',
          note: 'Недостаток питания, рост замедлен',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Норма',
          range: '500 – 1200 мкСм/см',
          note: 'Подходит для рассады и нежных культур (салат, зелень)',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Оптимум',
          range: '1200 – 2000 мкСм/см',
          note: 'Большинство плодовых: помидоры, огурцы, перец',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Высокая',
          range: '2000 – 2500 мкСм/см',
          note: 'Концентрированная фаза для крупных растений',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Слишком высокая',
          range: '> 2500 мкСм/см',
          note: 'Корни сжигаются осмосом, требуется разбавление',
          color: HelpPalette.danger,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Очищенная',
          range: '< 50 мкСм/см',
          note: 'Дистиллят или обратный осмос — почти без минералов',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Мягкая',
          range: '50 – 200 мкСм/см',
          note: 'Бутилированная и родниковая',
          color: HelpPalette.excellent,
        ),
        HelpRange(
          label: 'Норма',
          range: '200 – 500 мкСм/см',
          note: 'Типичная водопроводная очищенная',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Жёсткая',
          range: '500 – 1000 мкСм/см',
          note: 'Много минералов, накипь в чайнике',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Очень жёсткая',
          range: '1000 – 1500 мкСм/см',
          note: 'Граница питьевой по ВОЗ',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Не питьевая',
          range: '> 1500 мкСм/см',
          note: 'Сильно минерализована, для питья непригодна',
          color: HelpPalette.dangerDark,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'ec',
      title: 'Электропроводность (EC)',
      summary:
          'Сколько растворённых ионов в воде. Чем больше солей и минералов — тем выше '
          'проводимость. Дистиллированная вода почти не проводит ток.',
      sections: [
        const HelpSection(
          title: 'Зачем нужно',
          text:
              'EC и TDS тесно связаны — оба показывают общую минерализацию. EC измеряется в '
              'мкСм/см (микросименсах на сантиметр), TDS — в ppm (частей на миллион). Примерно: '
              'TDS ≈ EC × 0.5.',
        ),
        HelpSection(title: 'Тонкая градация', ranges: ranges),
      ],
    );
  }

  static ParameterHelp _tds(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'tds',
      title: 'Минерализация (TDS)',
      summary:
          'Общее количество растворённых твёрдых веществ — солей, минералов, металлов. '
          'Не путать с жёсткостью (только Ca/Mg). Измеряется в ppm.',
      sections: [
        HelpSection(
          title: 'Зачем нужно',
          text:
              'ВОЗ устанавливает 1000 ppm как верхнюю границу безопасной питьевой воды. '
              'Идеальная питьевая вода — 50–300 ppm: достаточно минералов для вкуса и пользы, '
              'но не настолько много, чтобы вызывать накипь и проблемы с почками.',
        ),
        HelpSection(
          title: 'Тонкая градация',
          ranges: [
            HelpRange(
              label: 'Дистиллят',
              range: '< 50 ppm',
              note: 'Обратный осмос или дистилляция, лишена минералов',
              color: HelpPalette.ideal,
            ),
            HelpRange(
              label: 'Идеальная',
              range: '50 – 300 ppm',
              note: 'Оптимальный баланс вкуса и пользы',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Норма',
              range: '300 – 600 ppm',
              note: 'Допустимо, типичный водопровод',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Жёсткая',
              range: '600 – 1000 ppm',
              note: 'Налёт, неприятный солоноватый привкус',
              color: HelpPalette.caution,
            ),
            HelpRange(
              label: 'Не питьевая',
              range: '> 1000 ppm',
              note: 'Выше нормы ВОЗ, для питья неподходит',
              color: HelpPalette.dangerDark,
            ),
          ],
        ),
        HelpSection(
          title: 'Полезный факт',
          text:
              'TDS не различает «хорошие» минералы (кальций, магний, калий) и «плохие» '
              '(свинец, мышьяк, нитраты). Низкий TDS не гарантирует чистоту, высокий не означает '
              'опасность. Для точной оценки нужен лабораторный анализ.',
        ),
      ],
    );
  }

  static ParameterHelp _salinity(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'salinity',
      title: 'Солёность',
      summary: 'Содержание солей в воде. Для пресной воды должна быть близка к нулю.',
      sections: [
        HelpSection(
          title: 'Тонкая градация',
          ranges: [
            HelpRange(
              label: 'Пресная',
              range: '< 100 ppm',
              note: 'Питьевая, аквариумная пресная, дождевая',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Слегка солоноватая',
              range: '100 – 500 ppm',
              note: 'Норма для большинства водопроводных систем',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Солоноватая',
              range: '500 – 1000 ppm',
              note: 'Граница, при которой вкус ощутим',
              color: HelpPalette.acceptable,
            ),
            HelpRange(
              label: 'Соленая',
              range: '1000 – 3000 ppm',
              note: 'Соляные бассейны, минеральная морская',
              color: HelpPalette.caution,
            ),
            HelpRange(
              label: 'Морская',
              range: '> 30 000 ppm',
              note: 'Океаническая вода (далеко за пределами шкалы тестера)',
              color: HelpPalette.dangerDark,
            ),
          ],
        ),
      ],
    );
  }

  static ParameterHelp _temperature(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.aquariumFresh => const [
        HelpRange(
          label: 'Опасно холодная',
          range: '< 18 °C',
          note: 'Замедляется метаболизм, болезни',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Прохладная',
          range: '18 – 22 °C',
          note: 'Холодноводные виды: золотые рыбки, гольяны',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Оптимум',
          range: '22 – 27 °C',
          note: 'Большинство тропических пресноводных',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Тёплая',
          range: '27 – 30 °C',
          note: 'Дискусы, некоторые цихлиды',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Опасно горячая',
          range: '> 30 °C',
          note: 'Кислород падает, рыбы задыхаются',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.pool => const [
        HelpRange(
          label: 'Холодная',
          range: '< 20 °C',
          note: 'Спортивные бассейны',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Прохладная',
          range: '20 – 25 °C',
          note: 'Активное плавание',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Комфорт',
          range: '25 – 30 °C',
          note: 'Рекреационная температура',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Тёплая',
          range: '30 – 35 °C',
          note: 'Дети, грязевая активность бактерий',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Перегрета',
          range: '> 35 °C',
          note: 'Дезинфекция малоэффективна, риск бактерий',
          color: HelpPalette.danger,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Очень холодная',
          range: '< 5 °C',
          note: 'Зимняя вода, пить нежелательно (стресс желудку)',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Холодная',
          range: '5 – 15 °C',
          note: 'Идеальна для жажды, ощущение свежести',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Комнатная',
          range: '15 – 25 °C',
          note: 'Лучше усваивается, нейтральная',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Тёплая',
          range: '25 – 35 °C',
          note: 'Не освежает, но усваивается легко',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Горячая',
          range: '> 35 °C',
          note: 'Чай, не для питья «как воды»',
          color: HelpPalette.acceptable,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'temperature',
      title: 'Температура',
      summary:
          'Температура воды в градусах Цельсия. Влияет на восприятие вкуса, скорость '
          'химических процессов, растворимость кислорода.',
      sections: [HelpSection(title: 'Тонкая градация', ranges: ranges)],
    );
  }

  static ParameterHelp _sg(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'sg',
      title: 'Плотность воды (S.G.)',
      summary:
          'Удельный вес — отношение плотности воды к плотности чистой воды при 4 °C. '
          'Чистая пресная вода имеет S.G. = 1.000.',
      sections: [
        HelpSection(
          title: 'Зачем нужно',
          text:
              'Используется в аквариумистике (морская вода 1.022–1.028), пивоварении и виноделии '
              '(плотность сусла), геологии. Для питьевой воды малоинформативно — почти всегда близко к 1.000.',
        ),
        HelpSection(
          title: 'Тонкая градация',
          ranges: [
            HelpRange(
              label: 'Талая',
              range: '< 0.998',
              note: 'Очень чистая, дистиллят',
              color: HelpPalette.ideal,
            ),
            HelpRange(
              label: 'Пресная',
              range: '0.998 – 1.005',
              note: 'Норма для питьевой и аквариумной пресной',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Минерализованная',
              range: '1.005 – 1.020',
              note: 'Минеральная, солоноватая',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Морская',
              range: '1.020 – 1.030',
              note: 'Океан, морской аквариум',
              color: HelpPalette.acceptable,
            ),
            HelpRange(
              label: 'Рассол',
              range: '> 1.030',
              note: 'Соляной раствор',
              color: HelpPalette.caution,
            ),
          ],
        ),
      ],
    );
  }
}
