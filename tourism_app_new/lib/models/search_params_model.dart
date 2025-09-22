import 'package:flutter/material.dart';

class SearchParams {
  final double? latitude;
  final double? longitude;
  final double radius;
  final String locationName;
  final DateTime checkInDate;
  final TimeOfDay checkInTime;
  final int durationHours;
  final int adults;
  final int children;
  final int rooms;

  SearchParams({
    this.latitude,
    this.longitude,
    this.radius = 10.0, // Default radius of 10km
    required this.locationName,
    required this.checkInDate,
    required this.checkInTime,
    required this.durationHours,
    required this.adults,
    required this.children,
    required this.rooms,
  });
}
