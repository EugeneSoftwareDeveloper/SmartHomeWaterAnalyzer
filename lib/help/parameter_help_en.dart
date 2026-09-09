import '../quality/profile.dart';
import 'parameter_help.dart';

/// Содержимое справки на английском — точная копия структуры русского файла.
///
/// Границы, цвета и порядок разделов обязаны совпадать до символа: пользователь
/// на любом языке видит одну и ту же градацию, просто подписанную по-своему.
/// Это проверяется тестом, а не аккуратностью — сверить две сотни строк глазами
/// нельзя.
abstract final class EnglishParameterHelp {
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
          label: 'Strongly acidic',
          range: '< 6.8',
          note: 'Irritates skin and eyes, destroys disinfectants',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Acidic',
          range: '6.8 – 7.2',
          note: 'Chlorine works worse, needs raising',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Ideal',
          range: '7.2 – 7.6',
          note: 'Peak disinfection, neutral on skin',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Acceptable',
          range: '7.6 – 7.8',
          note: 'Tolerable, but chlorine already works worse',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'High',
          range: '7.8 – 8.4',
          note: 'Cloudiness, scale deposits, chlorine loses its punch',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Strongly alkaline',
          range: '> 8.4',
          note: 'Acidify now, limescale is inevitable',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.aquariumFresh => const [
        HelpRange(
          label: 'Dangerously acidic',
          range: '< 5.5',
          note: 'Stress and death for most fish',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Acidic',
          range: '5.5 – 6.5',
          note: 'Suits discus, neons, some tetras',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Slightly acidic',
          range: '6.5 – 7.0',
          note: 'Most tropical freshwater species',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Neutral',
          range: '7.0 – 7.5',
          note: 'The all-round range, optimal for most',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Slightly alkaline',
          range: '7.5 – 8.2',
          note: 'Malawi and Tanganyika cichlids, guppies, mollies',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Alkaline',
          range: '8.2 – 9.0',
          note: 'Specialist species only',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Dangerously alkaline',
          range: '> 9.0',
          note: 'Ammonia turns toxic, act immediately',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.hydroponics => const [
        HelpRange(
          label: 'Dangerously acidic',
          range: '< 4.5',
          note: 'Roots are damaged, nutrient uptake breaks down',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Acidic',
          range: '4.5 – 5.5',
          note: 'Suits blueberries, azaleas, some flowers',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Normal',
          range: '5.5 – 5.8',
          note: 'Iron, manganese and zinc are more available',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Optimum',
          range: '5.8 – 6.5',
          note: 'Works for most crops: tomatoes, cucumbers, lettuce',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Normal',
          range: '6.5 – 7.0',
          note: 'Fine for most, but iron and manganese are less available',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'High',
          range: '7.0 – 8.0',
          note: 'Micronutrient deficiency, correct with acid',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Dangerously alkaline',
          range: '> 8.0',
          note: 'Nutrients are not taken up, salts precipitate',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.drinking => const [
        HelpRange(
          label: 'Strongly acidic',
          range: '< 4.5',
          note: 'Erodes tooth enamel and the stomach lining',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Acidic',
          range: '4.5 – 6.0',
          note: 'Not for everyday drinking',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Slightly acidic',
          range: '6.0 – 6.5',
          note: 'Tolerable; the WHO advises against below 6.5',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Normal',
          range: '6.5 – 7.2',
          note: 'Close to neutral, safe for everyday drinking',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Ideal',
          range: '7.2 – 7.8',
          note: 'Matches blood pH (7.4), the most physiological range',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Normal',
          range: '7.8 – 8.5',
          note: 'The upper bound of the WHO recommendation',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Slightly alkaline',
          range: '8.5 – 9.5',
          note: 'Mineral water; not for the long run',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Alkaline',
          range: '9.5 – 10.5',
          note: 'Can irritate, tastes unpleasantly soapy',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Strongly alkaline',
          range: '> 10.5',
          note: 'Dangerous for digestion',
          color: HelpPalette.dangerDark,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'ph',
      title: 'Acidity (pH)',
      summary:
          'Tells whether the water is acidic, neutral or alkaline. '
          'The scale runs from 0 (concentrated acid) to 14 (concentrated alkali). '
          'Neutral water sits at 7.0.',
      sections: [
        HelpSection(
          title: 'Why it matters',
          text: profile == NormsProfile.drinking
              ? 'Water that is too acidic or too alkaline upsets digestion, erodes tooth enamel '
                    'and corrodes pipes (that metallic aftertaste). The WHO range for drinking '
                    'water is 6.5–8.5.'
              : 'pH governs which ions are available and how fast chemistry runs. Every scenario '
                    'has its own optimum.',
        ),
        HelpSection(title: 'Fine gradation', ranges: ranges),
        const HelpSection(
          title: 'Note',
          text:
              'pH can drift a little between readings — that is normal, the electrode '
              'settles over time. For a solid figure, take 2-3 readings in a row.',
        ),
      ],
    );
  }

  static ParameterHelp _orp(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.pool => const [
        HelpRange(
          label: 'Dangerously low',
          range: '< 600 mV',
          note: 'Disinfection is ineffective; bacteria and algae take hold',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'A bit low',
          range: '600 – 650 mV',
          note: 'Not enough chlorine, needs topping up',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Ideal',
          range: '650 – 750 mV',
          note: 'The level the WHO recommends for safe water',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'High',
          range: '750 – 850 mV',
          note: 'Heavy chlorination: safe, but hard on skin',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Too high',
          range: '> 850 mV',
          note: 'Disinfectant overdose, check the chlorine level',
          color: HelpPalette.caution,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Strongly reducing',
          range: '< −100 mV',
          note: 'An antioxidant environment, typical of meltwater and spring water',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Neutral',
          range: '−100 – 200 mV',
          note: 'No pronounced character',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Ideal',
          range: '200 – 400 mV',
          note: 'The typical range of clean drinking water',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Normal',
          range: '400 – 600 mV',
          note: 'Mildly oxidizing, safe',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Oxidizing',
          range: '600 – 800 mV',
          note: 'Chlorinated tap water',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Strongly oxidizing',
          range: '> 800 mV',
          note: 'Active disinfection; not for everyday drinking',
          color: HelpPalette.caution,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'orp',
      title: 'Redox potential (ORP)',
      summary:
          'Measures how oxidizing or reducing the water is. Positive values are typical '
          'of water that can oxidize (chlorine, oxygen); negative ones belong to water '
          'with antioxidant properties.',
      sections: [
        HelpSection(
          title: 'Why it matters',
          text: profile == NormsProfile.pool
              ? 'For pools, ORP is the headline measure of disinfection. The WHO '
                    'recommends ≥650 mV — at that level bacteria die within seconds.'
              : 'It follows chlorine, ozone and oxygen. Clean spring water has a low '
                    'ORP (antioxidant); chlorinated tap water has a high one.',
        ),
        HelpSection(title: 'Fine gradation', ranges: ranges),
      ],
    );
  }

  static ParameterHelp _ec(NormsProfile profile) {
    final ranges = switch (profile) {
      NormsProfile.hydroponics => const [
        HelpRange(
          label: 'Weak',
          range: '< 500 µS/cm',
          note: 'Not enough nutrients, growth slows down',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Normal',
          range: '500 – 1200 µS/cm',
          note: 'Suits seedlings and delicate crops (lettuce, herbs)',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Optimum',
          range: '1200 – 2000 µS/cm',
          note: 'Most fruiting crops: tomatoes, cucumbers, peppers',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'High',
          range: '2000 – 2500 µS/cm',
          note: 'The concentrated phase for large plants',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Too high',
          range: '> 2500 µS/cm',
          note: 'Osmosis burns the roots, dilute the solution',
          color: HelpPalette.danger,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Purified',
          range: '< 50 µS/cm',
          note: 'Distilled or reverse osmosis — almost no minerals',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Soft',
          range: '50 – 200 µS/cm',
          note: 'Bottled and spring water',
          color: HelpPalette.excellent,
        ),
        HelpRange(
          label: 'Normal',
          range: '200 – 500 µS/cm',
          note: 'Typical treated tap water',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Hard',
          range: '500 – 1000 µS/cm',
          note: 'Plenty of minerals, scale in the kettle',
          color: HelpPalette.acceptable,
        ),
        HelpRange(
          label: 'Very hard',
          range: '1000 – 1500 µS/cm',
          note: 'The WHO limit for drinking water',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Not drinkable',
          range: '> 1500 µS/cm',
          note: 'Heavily mineralized, unfit for drinking',
          color: HelpPalette.dangerDark,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'ec',
      title: 'Conductivity (EC)',
      summary:
          'How many dissolved ions the water carries. More salts and minerals means higher '
          'conductivity. Distilled water barely conducts at all.',
      sections: [
        const HelpSection(
          title: 'Why it matters',
          text:
              'EC and TDS are two views of the same thing — total mineral content. EC is measured in '
              'µS/cm (microsiemens per centimetre), TDS in ppm (parts per million). Roughly: '
              'TDS ≈ EC × 0.5.',
        ),
        HelpSection(title: 'Fine gradation', ranges: ranges),
      ],
    );
  }

  static ParameterHelp _tds(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'tds',
      title: 'Dissolved solids (TDS)',
      summary:
          'The total of dissolved solids — salts, minerals, metals. '
          'Not the same as hardness (Ca/Mg only). Measured in ppm.',
      sections: [
        HelpSection(
          title: 'Why it matters',
          text:
              'The WHO puts 1000 ppm as the upper bound for safe drinking water. '
              'Ideal drinking water is 50–300 ppm: enough minerals for taste and benefit, '
              'but not so many that you get scale and kidney trouble.',
        ),
        HelpSection(
          title: 'Fine gradation',
          ranges: [
            HelpRange(
              label: 'Distilled',
              range: '< 50 ppm',
              note: 'Reverse osmosis or distillation, stripped of minerals',
              color: HelpPalette.ideal,
            ),
            HelpRange(
              label: 'Ideal',
              range: '50 – 300 ppm',
              note: 'The best balance of taste and benefit',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Normal',
              range: '300 – 600 ppm',
              note: 'Tolerable; typical tap water',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Hard',
              range: '600 – 1000 ppm',
              note: 'Scale and an unpleasant brackish aftertaste',
              color: HelpPalette.caution,
            ),
            HelpRange(
              label: 'Not drinkable',
              range: '> 1000 ppm',
              note: 'Above the WHO limit, not fit for drinking',
              color: HelpPalette.dangerDark,
            ),
          ],
        ),
        HelpSection(
          title: 'Worth knowing',
          text:
              'TDS does not tell “good” minerals (calcium, magnesium, potassium) from “bad” ones '
              '(lead, arsenic, nitrates). A low TDS is no guarantee of purity, a high one is no '
              'proof of danger. A real answer needs a lab test.',
        ),
      ],
    );
  }

  static ParameterHelp _salinity(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'salinity',
      title: 'Salinity',
      summary: 'How much salt the water carries. Fresh water should be close to zero.',
      sections: [
        HelpSection(
          title: 'Fine gradation',
          ranges: [
            HelpRange(
              label: 'Fresh',
              range: '< 100 ppm',
              note: 'Drinking water, freshwater aquariums, rainwater',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Slightly brackish',
              range: '100 – 500 ppm',
              note: 'Normal for most municipal supplies',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Brackish',
              range: '500 – 1000 ppm',
              note: 'The point where you start to taste it',
              color: HelpPalette.acceptable,
            ),
            HelpRange(
              label: 'Salty',
              range: '1000 – 3000 ppm',
              note: 'Saltwater pools, mineral sea water',
              color: HelpPalette.caution,
            ),
            HelpRange(
              label: 'Sea water',
              range: '> 30 000 ppm',
              note: 'Ocean water (far beyond the meter’s scale)',
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
          label: 'Dangerously cold',
          range: '< 18 °C',
          note: 'Metabolism slows down, disease follows',
          color: HelpPalette.dangerDark,
        ),
        HelpRange(
          label: 'Cool',
          range: '18 – 22 °C',
          note: 'Coldwater species: goldfish, minnows',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Optimum',
          range: '22 – 27 °C',
          note: 'Most tropical freshwater fish',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Warm',
          range: '27 – 30 °C',
          note: 'Discus and some cichlids',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Dangerously hot',
          range: '> 30 °C',
          note: 'Oxygen drops, the fish suffocate',
          color: HelpPalette.dangerDark,
        ),
      ],
      NormsProfile.pool => const [
        HelpRange(
          label: 'Cold',
          range: '< 20 °C',
          note: 'Competition pools',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Cool',
          range: '20 – 25 °C',
          note: 'Active swimming',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Comfort',
          range: '25 – 30 °C',
          note: 'Recreational temperature',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Warm',
          range: '30 – 35 °C',
          note: 'Children; bacteria get busy',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Overheated',
          range: '> 35 °C',
          note: 'Disinfection barely works, bacteria thrive',
          color: HelpPalette.danger,
        ),
      ],
      _ => const [
        HelpRange(
          label: 'Very cold',
          range: '< 5 °C',
          note: 'Winter water; drinking it stresses the stomach',
          color: HelpPalette.caution,
        ),
        HelpRange(
          label: 'Cold',
          range: '5 – 15 °C',
          note: 'Ideal for thirst, tastes fresh',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Room',
          range: '15 – 25 °C',
          note: 'Absorbed better, neutral',
          color: HelpPalette.ideal,
        ),
        HelpRange(
          label: 'Warm',
          range: '25 – 35 °C',
          note: 'Not refreshing, but goes down easily',
          color: HelpPalette.good,
        ),
        HelpRange(
          label: 'Hot',
          range: '> 35 °C',
          note: 'For tea, not for drinking as water',
          color: HelpPalette.acceptable,
        ),
      ],
    };

    return ParameterHelp(
      parameterKey: 'temperature',
      title: 'Temperature',
      summary:
          'Water temperature in degrees Celsius. It shapes how the water tastes, how fast '
          'chemistry runs and how much oxygen dissolves.',
      sections: [HelpSection(title: 'Fine gradation', ranges: ranges)],
    );
  }

  static ParameterHelp _sg(NormsProfile profile) {
    return const ParameterHelp(
      parameterKey: 'sg',
      title: 'Water density (S.G.)',
      summary:
          'Specific gravity — the density of the water against pure water at 4 °C. '
          'Pure fresh water sits at S.G. = 1.000.',
      sections: [
        HelpSection(
          title: 'Why it matters',
          text:
              'Used in the aquarium hobby (sea water 1.022–1.028), in brewing and winemaking '
              '(wort gravity), and in geology. For drinking water it says little — it is almost always near 1.000.',
        ),
        HelpSection(
          title: 'Fine gradation',
          ranges: [
            HelpRange(
              label: 'Meltwater',
              range: '< 0.998',
              note: 'Very clean, distilled',
              color: HelpPalette.ideal,
            ),
            HelpRange(
              label: 'Fresh',
              range: '0.998 – 1.005',
              note: 'Normal for drinking water and freshwater tanks',
              color: HelpPalette.excellent,
            ),
            HelpRange(
              label: 'Mineralized',
              range: '1.005 – 1.020',
              note: 'Mineral, brackish',
              color: HelpPalette.good,
            ),
            HelpRange(
              label: 'Sea water',
              range: '1.020 – 1.030',
              note: 'The ocean, marine tanks',
              color: HelpPalette.acceptable,
            ),
            HelpRange(
              label: 'Brine',
              range: '> 1.030',
              note: 'A salt solution',
              color: HelpPalette.caution,
            ),
          ],
        ),
      ],
    );
  }
}
