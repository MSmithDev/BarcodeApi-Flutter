import 'dart:convert';

class BarcodeMeta {
  final String type;
  final String pattern;
  final String target;
  final String description;

  BarcodeMeta({this.type, this.pattern, this.target, this.description});

  factory BarcodeMeta.fromJson(Map<String, dynamic> json) {
    return BarcodeMeta(
        type: json['name'],
        pattern: json['pattern'],
        target: json['target'],
        description: json['description']);
  }

  @override
  String toString() {
    return 'API: $type {Pattern: $pattern, Target: $target, Description: $description}';
  }
}

class BarcodeApiTypes {
  List<dynamic> json;

  BarcodeApiTypes(String json) {
    //Array is passed
    this.json = jsonDecode(json);
  }

  List getTypes() {
    BarcodeMeta barcodeMeta;
    List typelist = [];
    json.forEach((element) {
      barcodeMeta = BarcodeMeta.fromJson(element);
      typelist.add(barcodeMeta.type);
    });

    // json.forEach((key, value) {
    //  // barcodeMeta = BarcodeMeta.fromJson(value);
    //   //typelist.add(barcodeMeta.type);
    // });

    return typelist;
  }
}
