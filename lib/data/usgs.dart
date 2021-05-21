import "dart:convert";

import "package:http/http.dart" as http;

import "package:tremblant_earth/data/core.dart";
import "package:tremblant_earth/utils.dart";

const uriDomain = "earthquake.usgs.gov";
const uriPath = "fdsnws/event/1";

// Docs: https://earthquake.usgs.gov/fdsnws/event/1/
Future<FeatureCollection?> query({
  // date/time range
  DateTime? startTime,
  DateTime? endTime,
  DateTime? updatedAfter,
  // rectangle bounding box
  double? minLatitude,
  double? minLongitude,
  double? maxLatitude,
  double? maxLongitude,
  // circular bounding box
  double? latitude,
  double? longitude,
  double? maxRadius,
  double? maxRadiusKm,
  // other
  String? catalog,
  String? contributor,
  String? eventId,
  bool? includeAllMagnitudes,
  bool? includeAllOrigins,
  bool? includeArrivals,
  bool? includeDeleted,
  bool? includeSuperseded,
  int? limit,
  double? maxDepth,
  double? maxMagnitude,
  double? minDepth,
  double? minMagnitude,
  int? offset,
  String? orderBy,
  // extensions (not exhaustive)
  String? alertLevel,
  String? eventType,
  double? maxCdi,
  double? maxGap,
  double? maxMmi,
  int? maxSig,
  double? minCdi,
  int? minFelt,
  double? minGap,
  int? minSig,
}) async {
  final format = "geojson";
  final now = DateTime.now();
  endTime ??= now;
  startTime ??= now.subtract(Duration(days: 30));

  if (startTime.isAfter(endTime)) {
    throw ArgumentError("start time must precede end time");
  }

  minLatitude?.validateInRange(-90.0, 90.0);
  minLongitude?.validateInRange(-360.0, 360.0);
  maxLatitude?.validateInRange(-90.0, 90.0);
  maxLongitude?.validateInRange(-360.0, 360.0);

  latitude?.validateInRange(-90.0, 90.0);
  longitude?.validateInRange(-180.0, 180.0);
  maxRadius?.validateInRange(0.0, 180.0);
  maxRadiusKm?.validateInRange(0.0, 20001.6);

  limit?.validateInRange(1, 20000);
  maxDepth?.validateInRange(-100.0, 1000.0);
  maxMagnitude?.validateMinimum(0.0);
  minDepth?.validateInRange(-100.0, 1000.0);
  minMagnitude?.validateMinimum(0.0);
  offset?.validateMinimum(1);

  maxCdi?.validateInRange(0.0, 12.0);
  maxGap?.validateInRange(0.0, 360.0);
  maxMmi?.validateInRange(0.0, 12.0);
  minFelt?.validateMinimum(0);
  minGap?.validateInRange(0.0, 360.0);

  final queryArgs = {
    "format": format,
    "starttime": startTime.toIso8601String(),
    "endtime": endTime.toIso8601String(),
    if (updatedAfter != null) "updatedafter": updatedAfter.toIso8601String(),
    if (minLatitude != null) "minlatitude": minLatitude,
    if (minLongitude != null) "minlongitude": minLongitude,
    if (maxLatitude != null) "maxlatitude": maxLatitude,
    if (maxLongitude != null) "maxlongitude": maxLongitude,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (maxRadius != null) "maxradius": maxRadius,
    if (maxRadiusKm != null) "maxradiuskm": maxRadiusKm,
    if (limit != null) "limit": limit,
    if (maxDepth != null) "maxdepth": maxDepth,
    if (maxMagnitude != null) "maxmagnitude": maxMagnitude,
    if (minDepth != null) "mindepth": minDepth,
    if (minMagnitude != null) "minmagnitude": minMagnitude,
    if (offset != null) "offset": offset,
    if (alertLevel != null) "alertlevel": alertLevel,
    if (eventType != null) "eventtype": eventType,
    if (maxCdi != null) "maxcdi": maxCdi,
    if (maxGap != null) "maxgap": maxGap,
    if (maxMmi != null) "maxmmi": maxMmi,
    if (maxSig != null) "maxsig": maxSig,
    if (minCdi != null) "mincdi": minCdi,
    if (minFelt != null) "minfelt": minFelt,
    if (minGap != null) "mingap": minGap,
    if (minSig != null) "minsig": minSig,
  };

  final headers = {
    "Content-Type": "application/json",
  };

  final uri = Uri.https(uriDomain, "$uriPath/query", queryArgs);
  final response = await http.get(uri, headers: headers);

  if (response.statusCode != 200) {
    return null;
  }

  return FeatureCollection.fromJson(jsonDecode(response.body));
}

enum FeatureCollectionType { FeatureCollection }

class FeatureCollection {
  final FeatureCollectionType type;
  final Metadata metadata;
  final List<double> bbox;
  final List<Feature> features;

  FeatureCollection({
    required this.type,
    required this.metadata,
    required this.bbox,
    required this.features,
  });

  factory FeatureCollection.fromJson(Map<String, dynamic> json) {
    return FeatureCollection(
        type: typeFromString(json["type"]),
        metadata: Metadata.fromJson(json["metadata"]),
        bbox: listFromJson<dynamic, double>(
            json["bbox"], (x) => doubleFromJson(x) ?? double.nan),
        features: listFromJson<Map<String, dynamic>, Feature>(
            json["features"], (x) => Feature.fromJson(x)));
  }

  static FeatureCollectionType typeFromString(String? type) {
    switch (type) {
      case "FeatureCollection":
        return FeatureCollectionType.FeatureCollection;
      default:
        throw Exception("unrecognized FeatureCollectionType");
    }
  }
}

class Metadata {
  final DateTime generated;
  final String url;
  final String title;
  final int status;
  final String api;
  final int count;

  Metadata({
    required this.generated,
    required this.url,
    required this.title,
    required this.status,
    required this.api,
    required this.count,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      generated: DateTime.fromMillisecondsSinceEpoch(json["generated"]),
      url: json["url"],
      title: json["title"],
      status: json["status"],
      api: json["api"],
      count: json["count"],
    );
  }
}

enum FeatureType { Feature }

class Feature {
  final FeatureType type;
  final String id;
  final Properties properties;
  final Geometry geometry;

  Feature({
    required this.type,
    required this.id,
    required this.properties,
    required this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      type: typeFromString(json["type"]),
      id: json["id"],
      properties: Properties.fromJson(json["properties"]),
      geometry: Geometry.fromJson(json["geometry"]),
    );
  }

  static FeatureType typeFromString(String? type) {
    switch (type) {
      case "Feature":
        return FeatureType.Feature;
      default:
        throw Exception("unrecognized FeatureType");
    }
  }
}

enum GeometryType { Point }

class Geometry {
  final GeometryType type;
  final String? id;
  final List<double> coordinates;

  Geometry({
    required this.type,
    required this.id,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: typeFromString(json["type"]),
      id: json["id"],
      coordinates: listFromJson<dynamic, double>(
          json["coordinates"], (x) => doubleFromJson(x) ?? double.nan),
    );
  }

  static GeometryType typeFromString(String? type) {
    switch (type) {
      case "Point":
        return GeometryType.Point;
      default:
        throw Exception("unrecognized GeometryType");
    }
  }
}

class Properties {
  final double? mag;
  final String? place;
  final DateTime? time;
  final DateTime? updated;
  final int? tz;
  final String? url;
  final int? felt;
  final double? cdi;
  final double? mmi;
  final String? alert;
  final String? status;
  final int? tsunami;
  final int? sig;
  final String? net;
  final String? code;
  final String? ids;
  final String? sources;
  final String? types;
  final int? nst;
  final double? dmin;
  final double? rms;
  final double? gap;
  final String? magType;
  final String? type;
  final Map<String, Product>? products;

  Properties({
    this.mag,
    this.place,
    this.time,
    this.updated,
    this.tz,
    this.url,
    this.felt,
    this.cdi,
    this.mmi,
    this.alert,
    this.status,
    this.tsunami,
    this.sig,
    this.net,
    this.code,
    this.ids,
    this.sources,
    this.types,
    this.nst,
    this.dmin,
    this.rms,
    this.gap,
    this.magType,
    this.type,
    this.products,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      mag: doubleFromJson(json["mag"]),
      place: json["place"].toString(),
      time: DateTime.fromMillisecondsSinceEpoch(json["time"]),
      updated: DateTime.fromMillisecondsSinceEpoch(json["updated"]),
      tz: intFromJson(json["tz"]),
      url: json["url"].toString(),
      felt: intFromJson(json["felt"]),
      cdi: doubleFromJson(json["cdi"]),
      mmi: doubleFromJson(json["mmi"]),
      alert: json["alert"].toString(),
      status: json["status"].toString(),
      tsunami: intFromJson(json["tsunami"]),
      sig: intFromJson(json["sig"]),
      net: json["net"].toString(),
      code: json["code"].toString(),
      ids: json["ids"].toString(),
      sources: json["sources"].toString(),
      types: json["types"].toString(),
      nst: intFromJson(json["nst"]),
      dmin: doubleFromJson(json["dmin"]),
      rms: doubleFromJson(json["rms"]),
      gap: doubleFromJson(json["gap"]),
      magType: json["magType"].toString(),
      type: json["type"].toString(),
      products: mapFromJson<Map<String, dynamic>, Product>(
          json["products"], (x) => Product.fromJson(x)),
    );
  }
}

class Product {
  final String type;
  final String id;
  final String code;
  final String source;
  final DateTime updateTime;
  final String status;
  final int preferredWeight;
  final Map<String, String> properties;
  final Map<String, Contents> contents;

  Product({
    required this.type,
    required this.id,
    required this.code,
    required this.source,
    required this.updateTime,
    required this.status,
    required this.preferredWeight,
    required this.properties,
    required this.contents,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      type: json["type"],
      id: json["id"],
      code: json["code"],
      source: json["source"],
      updateTime: DateTime.fromMillisecondsSinceEpoch(json["updateTime"]),
      status: json["status"],
      preferredWeight: json["preferredWeight"],
      properties: json["properties"] as Map<String, String>,
      contents: mapFromJson<Map<String, dynamic>, Contents>(
          json["contents"], (x) => Contents.fromJson(x)),
    );
  }
}

class Contents {
  final String contentType;
  final DateTime lastModified;
  final int length;
  final String url;

  Contents({
    required this.contentType,
    required this.lastModified,
    required this.length,
    required this.url,
  });

  factory Contents.fromJson(Map<String, dynamic> json) {
    return Contents(
        contentType: json["contentType"],
        lastModified: DateTime.fromMillisecondsSinceEpoch(json["lastModified"]),
        length: json["length"],
        url: json["url"]);
  }
}
