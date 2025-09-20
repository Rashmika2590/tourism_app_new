import 'package:flutter/material.dart';

class SearchParams {
  final String state;
  final DateTime checkInDate;
  final TimeOfDay checkInTime;
  final int durationHours;
  final int adults;
  final int children;
  final int rooms;

  SearchParams({
    required this.state,
    required this.checkInDate,
    required this.checkInTime,
    required this.durationHours,
    required this.adults,
    required this.children,
    required this.rooms,
  });
}
