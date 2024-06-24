import 'dart:convert';

class Points {
  final int x;
  final int y;

  Points({
    required this.x,
    required this.y,
  });

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      x: json['x'] ?? 0,
      y: json['y'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() {
    return 'Points(x: $x, y: $y)';
  }
}

class FaceFeatures {
  Points? rightEar;
  Points? leftEar;
  Points? rightEye;
  Points? leftEye;
  Points? rightCheek;
  Points? leftCheek;
  Points? rightMouth;
  Points? leftMouth;
  Points? noseBase;
  Points? bottomMouth;

  FaceFeatures({
    this.rightMouth,
    this.leftMouth,
    this.leftCheek,
    this.rightCheek,
    this.leftEye,
    this.rightEar,
    this.leftEar,
    this.rightEye,
    this.noseBase,
    this.bottomMouth,
  });

  factory FaceFeatures.fromJson(Map<String, dynamic> json) {
    return FaceFeatures(
      rightMouth: json['rightMouth'] != null
          ? Points.fromJson(json['rightMouth'])
          : null,
      leftMouth:
          json['leftMouth'] != null ? Points.fromJson(json['leftMouth']) : null,
      leftCheek:
          json['leftCheek'] != null ? Points.fromJson(json['leftCheek']) : null,
      rightCheek: json['rightCheek'] != null
          ? Points.fromJson(json['rightCheek'])
          : null,
      leftEye:
          json['leftEye'] != null ? Points.fromJson(json['leftEye']) : null,
      rightEar:
          json['rightEar'] != null ? Points.fromJson(json['rightEar']) : null,
      leftEar:
          json['leftEar'] != null ? Points.fromJson(json['leftEar']) : null,
      rightEye:
          json['rightEye'] != null ? Points.fromJson(json['rightEye']) : null,
      noseBase:
          json['noseBase'] != null ? Points.fromJson(json['noseBase']) : null,
      bottomMouth: json['bottomMouth'] != null
          ? Points.fromJson(json['bottomMouth'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rightMouth": rightMouth?.toJson(),
      "leftMouth": leftMouth?.toJson(),
      "leftCheek": leftCheek?.toJson(),
      "rightCheek": rightCheek?.toJson(),
      "leftEye": leftEye?.toJson(),
      "rightEar": rightEar?.toJson(),
      "leftEar": leftEar?.toJson(),
      "rightEye": rightEye?.toJson(),
      "noseBase": noseBase?.toJson(),
      "bottomMouth": bottomMouth?.toJson(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'rightMouth':
          rightMouth != null ? jsonEncode(rightMouth!.toJson()) : null,
      'leftMouth': leftMouth != null ? jsonEncode(leftMouth!.toJson()) : null,
      'leftCheek': leftCheek != null ? jsonEncode(leftCheek!.toJson()) : null,
      'rightCheek':
          rightCheek != null ? jsonEncode(rightCheek!.toJson()) : null,
      'leftEye': leftEye != null ? jsonEncode(leftEye!.toJson()) : null,
      'rightEar': rightEar != null ? jsonEncode(rightEar!.toJson()) : null,
      'leftEar': leftEar != null ? jsonEncode(leftEar!.toJson()) : null,
      'rightEye': rightEye != null ? jsonEncode(rightEye!.toJson()) : null,
      'noseBase': noseBase != null ? jsonEncode(noseBase!.toJson()) : null,
      'bottomMouth':
          bottomMouth != null ? jsonEncode(bottomMouth!.toJson()) : null,
    };
  }

  static FaceFeatures fromMap(Map<String, dynamic> map) {
    return FaceFeatures(
      rightMouth: map['rightMouth'] != null
          ? Points.fromJson(jsonDecode(map['rightMouth']))
          : null,
      leftMouth: map['leftMouth'] != null
          ? Points.fromJson(jsonDecode(map['leftMouth']))
          : null,
      leftCheek: map['leftCheek'] != null
          ? Points.fromJson(jsonDecode(map['leftCheek']))
          : null,
      rightCheek: map['rightCheek'] != null
          ? Points.fromJson(jsonDecode(map['rightCheek']))
          : null,
      leftEye: map['leftEye'] != null
          ? Points.fromJson(jsonDecode(map['leftEye']))
          : null,
      rightEar: map['rightEar'] != null
          ? Points.fromJson(jsonDecode(map['rightEar']))
          : null,
      leftEar: map['leftEar'] != null
          ? Points.fromJson(jsonDecode(map['leftEar']))
          : null,
      rightEye: map['rightEye'] != null
          ? Points.fromJson(jsonDecode(map['rightEye']))
          : null,
      noseBase: map['noseBase'] != null
          ? Points.fromJson(jsonDecode(map['noseBase']))
          : null,
      bottomMouth: map['bottomMouth'] != null
          ? Points.fromJson(jsonDecode(map['bottomMouth']))
          : null,
    );
  }

  String serializeFaceFeatures(FaceFeatures faceFeatures) {
    return jsonEncode(faceFeatures.toMap());
  }

  FaceFeatures deserializeFaceFeatures(String faceFeatures) {
    return FaceFeatures.fromMap(jsonDecode(faceFeatures));
  }

  @override
  String toString() {
    return 'FaceFeatures(rightEar: $rightEar, leftEar: $leftEar, rightMouth: $rightMouth, leftMouth: $leftMouth, rightEye: $rightEye, leftEye: $leftEye, rightCheek: $rightCheek, leftCheek: $leftCheek, noseBase: $noseBase, bottomMouth: $bottomMouth)';
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? image;
  final FaceFeatures? faceFeatures;
  final int? registeredOn;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.faceFeatures,
    required this.registeredOn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      faceFeatures: json['faceFeatures'] != null
          ? FaceFeatures.fromJson(jsonDecode(json['faceFeatures']))
          : null,
      registeredOn: json['registeredOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'faceFeatures':
          faceFeatures != null ? jsonEncode(faceFeatures!.toJson()) : null,
      'registeredOn': registeredOn,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'faceFeatures':
          faceFeatures != null ? jsonEncode(faceFeatures!.toJson()) : null,
      'registeredOn': registeredOn,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      faceFeatures: map['faceFeatures'] != null
          ? FaceFeatures.fromJson(jsonDecode(map['faceFeatures']))
          : null,
      registeredOn: map['registeredOn'],
    );
  }
}
