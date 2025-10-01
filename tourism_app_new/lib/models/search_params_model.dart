// models/search_params_model.dart
import 'package:flutter/material.dart';

class SearchParams {
  late final String state;
  final double? latitude;
  final double? longitude;
  final DateTime checkInDate;
  final TimeOfDay checkInTime;
  final int durationHours;
  final int adults;
  final int children;
  final int rooms;

  SearchParams({
    required this.state,
    this.latitude,
    this.longitude,
    required this.checkInDate,
    required this.checkInTime,
    required this.durationHours,
    required this.adults,
    required this.children,
    required this.rooms,
  });

  SearchParams copyWith({
    String? state,
    double? latitude,
    double? longitude,
    DateTime? checkInDate,
    TimeOfDay? checkInTime,
    int? durationHours,
    int? adults,
    int? children,
    int? rooms,
  }) {
    return SearchParams(
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      checkInDate: checkInDate ?? this.checkInDate,
      checkInTime: checkInTime ?? this.checkInTime,
      durationHours: durationHours ?? this.durationHours,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
    );
  }
}
