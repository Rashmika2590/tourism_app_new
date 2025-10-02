class Place {
  final String name;
  final double distance;
  final String type;
  final String address;

  Place({
    required this.name,
    required this.distance,
    required this.type,
    required this.address,
  });

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
