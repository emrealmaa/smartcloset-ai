import '../core/enums/body_enums.dart';
import '../core/enums/skin_enums.dart';
import '../core/enums/face_enums.dart';
import '../core/enums/style_enums.dart';

class CharacterProfile {
  final int? id;
  final String userId;

  // Fiziksel ölçüler
  final int heightCm;
  final double weightKg;
  final BodyType bodyType;
  final ShoulderWidth shoulderWidth;
  final TorsoLength torsoLength;
  final LegLength legLength;

  // Cilt
  final SkinDepth skinDepth;
  final SkinUndertone skinUndertone;

  // Yüz
  final FaceShape faceShape;
  final EyeColor eyeColor;

  // Saç & Sakal
  final HairColor hairColor;
  final HairLength hairLength;
  final HairTexture hairTexture;
  final BeardStyle beardStyle;

  // Stil tercihleri
  final List<StyleGoal> styleGoals;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterProfile({
    this.id,
    required this.userId,
    required this.heightCm,
    required this.weightKg,
    required this.bodyType,
    required this.shoulderWidth,
    required this.torsoLength,
    required this.legLength,
    required this.skinDepth,
    required this.skinUndertone,
    required this.faceShape,
    required this.eyeColor,
    required this.hairColor,
    required this.hairLength,
    required this.hairTexture,
    required this.beardStyle,
    required this.styleGoals,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'body_type': bodyType.name,
      'shoulder_width': shoulderWidth.name,
      'torso_length': torsoLength.name,
      'leg_length': legLength.name,
      'skin_depth': skinDepth.name,
      'skin_undertone': skinUndertone.name,
      'face_shape': faceShape.name,
      'eye_color': eyeColor.name,
      'hair_color': hairColor.name,
      'hair_length': hairLength.name,
      'hair_texture': hairTexture.name,
      'beard_style': beardStyle.name,
      'style_goals': styleGoals.map((e) => e.name).join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CharacterProfile.fromMap(Map<String, dynamic> map) {
    final goalsRaw = map['style_goals'] as String? ?? '';
    return CharacterProfile(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      heightCm: map['height_cm'] as int,
      weightKg: (map['weight_kg'] as num).toDouble(),
      bodyType: BodyType.values.byName(map['body_type'] as String),
      shoulderWidth: ShoulderWidth.values.byName(map['shoulder_width'] as String),
      torsoLength: TorsoLength.values.byName(map['torso_length'] as String),
      legLength: LegLength.values.byName(map['leg_length'] as String),
      skinDepth: SkinDepth.values.byName(map['skin_depth'] as String),
      skinUndertone: SkinUndertone.values.byName(map['skin_undertone'] as String),
      faceShape: FaceShape.values.byName(map['face_shape'] as String),
      eyeColor: EyeColor.values.byName(map['eye_color'] as String),
      hairColor: HairColor.values.byName(map['hair_color'] as String),
      hairLength: HairLength.values.byName(map['hair_length'] as String),
      hairTexture: HairTexture.values.byName(map['hair_texture'] as String),
      beardStyle: BeardStyle.values.byName(map['beard_style'] as String),
      styleGoals: goalsRaw.isEmpty
          ? []
          : goalsRaw.split(',').map((e) => StyleGoal.values.byName(e)).toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  CharacterProfile copyWith({
    int? id,
    String? userId,
    int? heightCm,
    double? weightKg,
    BodyType? bodyType,
    ShoulderWidth? shoulderWidth,
    TorsoLength? torsoLength,
    LegLength? legLength,
    SkinDepth? skinDepth,
    SkinUndertone? skinUndertone,
    FaceShape? faceShape,
    EyeColor? eyeColor,
    HairColor? hairColor,
    HairLength? hairLength,
    HairTexture? hairTexture,
    BeardStyle? beardStyle,
    List<StyleGoal>? styleGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CharacterProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyType: bodyType ?? this.bodyType,
      shoulderWidth: shoulderWidth ?? this.shoulderWidth,
      torsoLength: torsoLength ?? this.torsoLength,
      legLength: legLength ?? this.legLength,
      skinDepth: skinDepth ?? this.skinDepth,
      skinUndertone: skinUndertone ?? this.skinUndertone,
      faceShape: faceShape ?? this.faceShape,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      hairLength: hairLength ?? this.hairLength,
      hairTexture: hairTexture ?? this.hairTexture,
      beardStyle: beardStyle ?? this.beardStyle,
      styleGoals: styleGoals ?? this.styleGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
