class DashboardStatsModel {
  final int sessionsCount;
  final int newsCount;
  final int patientsCount;
  final int upcomingSessionsCount;

  DashboardStatsModel({
    required this.sessionsCount,
    required this.newsCount,
    required this.patientsCount,
    required this.upcomingSessionsCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      sessionsCount: json['sessionsCount'] ?? 0,
      newsCount: json['newsCount'] ?? 0,
      patientsCount: json['patientsCount'] ?? 0,
      upcomingSessionsCount: json['upcomingSessionsCount'] ?? 0,
    );
  }
}
