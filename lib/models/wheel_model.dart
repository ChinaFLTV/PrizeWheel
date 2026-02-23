import 'dart:convert';
import 'package:flutter/material.dart';

enum WheelStyle { classic, neon, candy, elegant, gradient, retro, ocean, sunset, metallic, pastel, dark, rainbow }

enum WheelSize { small, medium, large }

enum WheelForm { standard, petal, star, polygon }

enum SpinSpeed { slow, normal, fast }

enum PointerPosition { top, right }

class WheelSegment {
  String id;
  String label;
  double probability;
  Color color;
  double ratio;
  String? iconName;

  WheelSegment({
    required this.id,
    required this.label,
    this.probability = 0,
    this.color = Colors.blue,
    this.ratio = 1.0,
    this.iconName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'probability': probability,
    'color': color.toARGB32(),
    'ratio': ratio,
    'iconName': iconName,
  };

  factory WheelSegment.fromMap(Map<String, dynamic> map) => WheelSegment(
    id: map['id'] as String,
    label: map['label'] as String,
    probability: (map['probability'] as num).toDouble(),
    color: Color(map['color'] as int),
    ratio: (map['ratio'] as num).toDouble(),
    iconName: map['iconName'] as String?,
  );
}

class SpinRecord {
  String id;
  String wheelId;
  String wheelTitle;
  String prizeName;
  int prizeColor;
  DateTime spinTime;

  SpinRecord({
    required this.id,
    required this.wheelId,
    required this.wheelTitle,
    required this.prizeName,
    required this.prizeColor,
    required this.spinTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'wheelId': wheelId,
    'wheelTitle': wheelTitle,
    'prizeName': prizeName,
    'prizeColor': prizeColor,
    'spinTime': spinTime.toIso8601String(),
  };

  factory SpinRecord.fromMap(Map<String, dynamic> map) => SpinRecord(
    id: map['id'] as String,
    wheelId: map['wheelId'] as String,
    wheelTitle: map['wheelTitle'] as String,
    prizeName: map['prizeName'] as String,
    prizeColor: map['prizeColor'] as int,
    spinTime: DateTime.parse(map['spinTime'] as String),
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
  bool showResult;
  bool enableSound;
  bool is3D;
  String? backgroundImagePath;
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
    this.showResult = true,
    this.enableSound = true,
    this.is3D = false,
    this.backgroundImagePath,
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
    'showResult': showResult ? 1 : 0,
    'enableSound': enableSound ? 1 : 0,
    'is3D': is3D ? 1 : 0,
    'backgroundImagePath': backgroundImagePath,
    'segments': jsonEncode(segments.map((s) => s.toMap()).toList()),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WheelModel.fromMap(Map<String, dynamic> map) => WheelModel(
    id: map['id'] as String,
    title: map['title'] as String,
    style: WheelStyle.values[map['style'] as int],
    size: WheelSize.values[map['size'] as int],
    form: WheelForm.values[map['form'] as int],
    spinDuration: (map['spinDuration'] as num).toDouble(),
    spinSpeed: SpinSpeed.values[map['spinSpeed'] as int],
    pointerPosition: PointerPosition.values[map['pointerPosition'] as int],
    showResult: (map['showResult'] as int) == 1,
    enableSound: (map['enableSound'] as int) == 1,
    is3D: (map['is3D'] as int?) == 1,
    backgroundImagePath: map['backgroundImagePath'] as String?,
    segments: (jsonDecode(map['segments'] as String) as List)
        .map((s) => WheelSegment.fromMap(s as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
