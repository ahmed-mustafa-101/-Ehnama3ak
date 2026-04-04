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
      sessionsCount: json['sessionsCount'] ?? 
                     json['totalSessions'] ?? 
                     json['sessions'] ?? 
                     json['count'] ?? 0,
      newsCount: json['newsCount'] ?? 
                 json['notificationsCount'] ?? 
                 json['unreadNotifications'] ?? 
                 json['news'] ?? 0,
      patientsCount: json['patientsCount'] ?? 
                     json['totalPatients'] ?? 
                     json['patients'] ?? 0,
      upcomingSessionsCount: json['upcomingSessionsCount'] ?? 
                             json['upcomingSessions'] ?? 
                             json['futureSessions'] ?? 0,
    );
  }
}
