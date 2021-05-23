import "dart:convert";

import "package:http/http.dart" as http;

import "package:quake_explorer/data/core.dart";

const uriDomain = "earthquake.usgs.gov";
const uriPath = "fdsnws/event/1";

Future<FeatureCollection?> query(Map<String, Object?> queryArgs) async {
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
