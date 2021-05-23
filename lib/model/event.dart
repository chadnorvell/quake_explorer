import "package:quake_explorer/data/usgs.dart";
import "package:quake_explorer/utils.dart";

class Event {
  final String locationDescription;

  Event({
    required this.locationDescription,
  });

  factory Event.fromUsgsFeature(Feature feature) {
    return Event(locationDescription: feature.properties.place ?? "Unknown");
  }
}

// Docs: https://earthquake.usgs.gov/fdsnws/event/1/
class EventsQuery {
  // date/time range
  DateTime? startTime;
  DateTime? endTime;
  DateTime? updatedAfter;
  // rectangle bounding box
  double? minLatitude;
  double? minLongitude;
  double? maxLatitude;
  double? maxLongitude;
  // circular bounding box
  double? latitude;
  double? longitude;
  double? maxRadius;
  double? maxRadiusKm;
  // other
  String? catalog;
  String? contributor;
  String? eventId;
  bool? includeAllMagnitudes;
  bool? includeAllOrigins;
  bool? includeArrivals;
  bool? includeDeleted;
  bool? includeSuperseded;
  int? limit;
  double? maxDepth;
  double? maxMagnitude;
  double? minDepth;
  double? minMagnitude;
  int? offset;
  String? orderBy;
  // extensions (not exhaustive)
  String? alertLevel;
  String? eventType;
  double? maxCdi;
  double? maxGap;
  double? maxMmi;
  int? maxSig;
  double? minCdi;
  int? minFelt;
  double? minGap;
  int? minSig;

  Map<String, Object?> get queryArgs {
    return {
      "format": "geojson",
      if (startTime != null) "starttime": startTime?.toIso8601String(),
      if (endTime != null) "endtime": endTime?.toIso8601String(),
      if (updatedAfter != null) "updatedafter": updatedAfter?.toIso8601String(),
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
  }

  void _setDefaults() {
    final now = DateTime.now();
    endTime ??= now;
    startTime ??= now.subtract(Duration(days: 30));
  }

  void _validate() {
    if (startTime!.isAfter(endTime!)) {
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
  }

  Future<Iterable<Event>> fetch() async {
    _setDefaults();
    _validate();
    final response = await query(queryArgs);

    if (response == null) {
      return [];
    }

    return response.features.map((x) => Event.fromUsgsFeature(x));
  }
}
