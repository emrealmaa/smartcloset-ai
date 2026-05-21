enum BodyType { triangle, invertedTriangle, rectangle, oval, athletic }

enum ShoulderWidth { narrow, medium, wide }

enum TorsoLength { short, medium, long }

enum LegLength { short, medium, long }

extension BodyTypeX on BodyType {
  String get label => switch (this) {
        BodyType.triangle => 'Üçgen',
        BodyType.invertedTriangle => 'Ters Üçgen',
        BodyType.rectangle => 'Dikdörtgen',
        BodyType.oval => 'Oval',
        BodyType.athletic => 'Atletik',
      };

  String get description => switch (this) {
        BodyType.triangle => 'Omuz dar, kalça geniş',
        BodyType.invertedTriangle => 'Omuz geniş, kalça dar',
        BodyType.rectangle => 'Omuz, bel, kalça yakın ölçülerde',
        BodyType.oval => 'Bel ve karın öne çıkıyor',
        BodyType.athletic => 'Kaslı ve orantılı yapı',
      };

  String get emoji => switch (this) {
        BodyType.triangle => '▽',
        BodyType.invertedTriangle => '△',
        BodyType.rectangle => '▭',
        BodyType.oval => '⬭',
        BodyType.athletic => '◈',
      };
}

extension ShoulderWidthX on ShoulderWidth {
  String get label => switch (this) {
        ShoulderWidth.narrow => 'Dar',
        ShoulderWidth.medium => 'Orta',
        ShoulderWidth.wide => 'Geniş',
      };
}

extension TorsoLengthX on TorsoLength {
  String get label => switch (this) {
        TorsoLength.short => 'Kısa',
        TorsoLength.medium => 'Orta',
        TorsoLength.long => 'Uzun',
      };
}

extension LegLengthX on LegLength {
  String get label => switch (this) {
        LegLength.short => 'Kısa',
        LegLength.medium => 'Orta',
        LegLength.long => 'Uzun',
      };
}
