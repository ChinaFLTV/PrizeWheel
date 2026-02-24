import 'dart:convert';
import 'package:flutter/material.dart';

enum WheelStyle { classic, neon, candy, elegant, gradient, retro, ocean, sunset, metallic, pastel, dark, rainbow }

enum WheelSize { small, medium, large }

enum WheelForm { standard, petal, star, polygon }

enum SpinSpeed { slow, normal, fast }

enum PointerPosition { top, right, bottom, left }

enum PointerStyle { classic, arrow, diamond, dot, flag }

class WheelSegment {
  String id;
  String label;
  double probability;
  Color color;
  double ratio;
  String? iconName;
  double iconSize;
  double iconRotation; // radians

  WheelSegment({
    required this.id,
    required this.label,
    this.probability = 0,
    this.color = Colors.blue,
    this.ratio = 1.0,
    this.iconName,
    this.iconSize = 1.0,
    this.iconRotation = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'probability': probability,
    'color': color.toARGB32(),
    'ratio': ratio,
    'iconName': iconName,
    'iconSize': iconSize,
    'iconRotation': iconRotation,
  };

  factory WheelSegment.fromMap(Map<String, dynamic> map) => WheelSegment(
    id: map['id'] as String,
    label: map['label'] as String,
    probability: (map['probability'] as num).toDouble(),
    color: Color(map['color'] as int),
    ratio: (map['ratio'] as num).toDouble(),
    iconName: map['iconName'] as String?,
    iconSize: (map['iconSize'] as num?)?.toDouble() ?? 1.0,
    iconRotation: (map['iconRotation'] as num?)?.toDouble() ?? 0.0,
  );
}

class SpinRecord {
  String id;
  String wheelId;
  String wheelTitle;
  String prizeName;
  int prizeColor;
  DateTime spinTime;
  String? batchId; // non-null for batch spins, groups records together

  SpinRecord({
    required this.id,
    required this.wheelId,
    required this.wheelTitle,
    required this.prizeName,
    required this.prizeColor,
    required this.spinTime,
    this.batchId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'wheelId': wheelId,
    'wheelTitle': wheelTitle,
    'prizeName': prizeName,
    'prizeColor': prizeColor,
    'spinTime': spinTime.toIso8601String(),
    'batchId': batchId,
  };

  factory SpinRecord.fromMap(Map<String, dynamic> map) => SpinRecord(
    id: map['id'] as String,
    wheelId: map['wheelId'] as String,
    wheelTitle: map['wheelTitle'] as String,
    prizeName: map['prizeName'] as String,
    prizeColor: map['prizeColor'] as int,
    spinTime: DateTime.parse(map['spinTime'] as String),
    batchId: map['batchId'] as String?,
  );
}

class WheelModel {
  String id;
  String title;
  WheelStyle style;
  WheelSize size;
  WheelForm form;
  double spinDuration;
  SpinSpeed spinSpeed;
  PointerPosition pointerPosition;
  PointerStyle pointerStyle;
  bool showResult;
  bool enableSound;
  bool is3D;
  String? backgroundImagePath;
  bool bgBlurEnabled;
  double bgBlurIntensity;
  double bgOpacity;
  int bgOverlayColor;
  List<WheelSegment> segments;
  DateTime createdAt;
  DateTime updatedAt;

  WheelModel({
    required this.id,
    required this.title,
    this.style = WheelStyle.classic,
    this.size = WheelSize.medium,
    this.form = WheelForm.standard,
    this.spinDuration = 5.0,
    this.spinSpeed = SpinSpeed.normal,
    this.pointerPosition = PointerPosition.top,
    this.pointerStyle = PointerStyle.classic,
    this.showResult = true,
    this.enableSound = true,
    this.is3D = false,
    this.backgroundImagePath,
    this.bgBlurEnabled = false,
    this.bgBlurIntensity = 10.0,
    this.bgOpacity = 1.0,
    this.bgOverlayColor = 0x00000000,
    required this.segments,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'style': style.index,
    'size': size.index,
    'form': form.index,
    'spinDuration': spinDuration,
    'spinSpeed': spinSpeed.index,
    'pointerPosition': pointerPosition.index,
    'pointerStyle': pointerStyle.index,
    'showResult': showResult ? 1 : 0,
    'enableSound': enableSound ? 1 : 0,
    'is3D': is3D ? 1 : 0,
    'backgroundImagePath': backgroundImagePath,
    'bgBlurEnabled': bgBlurEnabled ? 1 : 0,
    'bgBlurIntensity': bgBlurIntensity,
    'bgOpacity': bgOpacity,
    'bgOverlayColor': bgOverlayColor,
    'segments': jsonEncode(segments.map((s) => s.toMap()).toList()),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static T _safeEnum<T extends Enum>(List<T> values, int index, T fallback) {
    return (index >= 0 && index < values.length) ? values[index] : fallback;
  }

  factory WheelModel.fromMap(Map<String, dynamic> map) => WheelModel(
    id: map['id'] as String,
    title: map['title'] as String,
    style: _safeEnum(WheelStyle.values, map['style'] as int, WheelStyle.classic),
    size: _safeEnum(WheelSize.values, map['size'] as int, WheelSize.medium),
    form: _safeEnum(WheelForm.values, map['form'] as int, WheelForm.standard),
    spinDuration: (map['spinDuration'] as num).toDouble(),
    spinSpeed: _safeEnum(SpinSpeed.values, map['spinSpeed'] as int, SpinSpeed.normal),
    pointerPosition: _safeEnum(PointerPosition.values, map['pointerPosition'] as int, PointerPosition.top),
    pointerStyle: _safeEnum(PointerStyle.values, (map['pointerStyle'] as int?) ?? 0, PointerStyle.classic),
    showResult: (map['showResult'] as int) == 1,
    enableSound: (map['enableSound'] as int) == 1,
    is3D: (map['is3D'] as int?) == 1,
    backgroundImagePath: map['backgroundImagePath'] as String?,
    bgBlurEnabled: (map['bgBlurEnabled'] as int?) == 1,
    bgBlurIntensity: (map['bgBlurIntensity'] as num?)?.toDouble() ?? 10.0,
    bgOpacity: (map['bgOpacity'] as num?)?.toDouble() ?? 1.0,
    bgOverlayColor: (map['bgOverlayColor'] as int?) ?? 0x00000000,
    segments: (jsonDecode(map['segments'] as String) as List)
        .map((s) => WheelSegment.fromMap(s as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
