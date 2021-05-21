Map<String, O> mapFromJson<I, O>(
    Map<String, dynamic>? json, O Function(I) ctor) {
  if (json == null) {
    return {};
  }

  Map<String, O> newMap = {};
  json.forEach((key, value) {
    newMap[key] = ctor(value);
  });
  return newMap;
}

List<O> listFromJson<I, O>(List<dynamic>? json, O Function(I) ctor) {
  if (json == null) {
    return [];
  }

  return json.map((x) => ctor(x)).toList();
}

double? doubleFromJson(dynamic json) {
  switch (json.runtimeType) {
    case double:
      return json;
    case int:
      return (json as int).toDouble();
    case String:
      return double.tryParse(json);
    default:
      return null;
  }
}

int? intFromJson(dynamic json) {
  switch (json.runtimeType) {
    case int:
      return json;
    case double:
      return (json as double).toInt();
    case String:
      return int.tryParse(json);
    default:
      return null;
  }
}
