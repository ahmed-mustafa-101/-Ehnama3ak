import 'package:ehnama3ak/screen_tap/progress/data/datasources/progress_api_service.dart';
import 'package:ehnama3ak/screen_tap/progress/presentation/cubit/progress_cubit.dart';
import 'package:ehnama3ak/screen_tap/therapist/data/datasources/doctor_api_service.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_cubit.dart';
import 'package:ehnama3ak/screens_app/profile/data/datasources/profile_api_service.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_cubit.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/data/datasources/doctor_dashboard_api_service.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/widgets/theme/theme_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_token_storage.dart';
import 'features/auth/data/datasources/auth_api_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_cubit.dart';
import 'features/feed/data/datasources/feed_api_service.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/presentation/cubit/feed_cubit.dart';
import 'features/podcasts/data/datasources/podcast_api_service.dart';
import 'features/podcasts/data/repositories/podcast_repository_impl.dart';
import 'features/podcasts/presentation/cubit/podcast_cubit.dart';
import 'features/resources/data/datasources/resource_api_service.dart';
import 'features/resources/data/repositories/resource_repository_impl.dart';
import 'features/resources/presentation/cubit/resource_cubit.dart';
import 'features/settings/data/datasources/settings_api_service.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/controllers/settings_cubit.dart';
import 'features/help_support/data/datasources/help_api_service.dart';
import 'features/help_support/data/repositories/help_repository_impl.dart';
import 'features/help_support/presentation/controllers/help_cubit.dart';
import 'features/splash/auth_wrapper.dart';
import 'screens_app/doctor/sessions/data/datasources/doctor_sessions_api_service.dart';
import 'screens_app/doctor/sessions/presentation/cubit/doctor_sessions_cubit.dart';
import 'screens_app/doctor/doctor_patients/data/datasources/doctor_patients_api_service.dart';
import 'screens_app/doctor/doctor_patients/presentation/cubit/doctor_patients_cubit.dart';
import 'screens_app/doctor/reports/data/datasources/doctor_reports_api_service.dart';
import 'screens_app/doctor/reports/presentation/cubit/doctor_reports_cubit.dart';
import 'features/notifications/data/datasources/notification_api_service.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/messages/data/datasources/message_api_service.dart';
import 'features/messages/data/repositories/message_repository_impl.dart';
import 'features/messages/presentation/controllers/message_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EhnaMa3akApp());
}

class EhnaMa3akApp extends StatelessWidget {
  const EhnaMa3akApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureTokenStorage();
    final apiService = AuthApiService(tokenStorage: storage);
    final dioClient = DioClient(tokenStorage: storage);
    final feedRepo = FeedRepositoryImpl(
      FeedApiService(dioClient: dioClient, tokenStorage: storage),
    );
    final podcastRepo = PodcastRepositoryImpl(
      PodcastApiService(dioClient: dioClient),
    );
    final resourceRepo = ResourceRepositoryImpl(
      ResourceApiService(dioClient: dioClient),
    );
    final settingsRepo = SettingsRepositoryImpl(
      SettingsApiService(dioClient: dioClient),
    );
    final helpRepo = HelpRepositoryImpl(HelpApiService(dioClient: dioClient));

    return RepositoryProvider<FeedRepository>.value(
      value: feedRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit()..loadSavedLocale()),
          BlocProvider(
            create: (context) =>
                AuthCubit(AuthRepositoryImpl(apiService, storage)),
          ),
          BlocProvider(create: (context) => FeedCubit(feedRepo)),
          BlocProvider(create: (context) => PodcastCubit(podcastRepo)),
          BlocProvider(create: (context) => ResourceCubit(resourceRepo)),
          BlocProvider(
              create: (context) => SettingsCubit(settingsRepo, storage)),
          BlocProvider(create: (context) => HelpCubit(helpRepo)),
          BlocProvider(
            create: (context) => DoctorSessionsCubit(
              DoctorSessionsApiService(dio: dioClient.dio),
            ),
          ),
          BlocProvider(
            create: (context) => DoctorPatientsCubit(
              DoctorPatientsApiService(dio: dioClient.dio),
            ),
          ),
          BlocProvider(
            create: (context) => DoctorReportsCubit(
                DoctorReportsApiService(dio: dioClient.dio)),
          ),
          BlocProvider(
            create: (context) => NotificationCubit(
              NotificationRepositoryImpl(
                NotificationApiService(dioClient: dioClient),
              ),
            )..loadUnreadCount(),
          ),
          BlocProvider(
            create: (context) => MessageCubit(
              MessageRepositoryImpl(MessageApiService(dioClient: dioClient)),
            )..loadUnreadCount(),
          ),
          BlocProvider(
            create: (context) => ProgressCubit(
              progressApiService: ProgressApiService(dio: dioClient.dio),
            ),
          ),
          BlocProvider(
            create: (context) => DoctorCubit(
              doctorApiService: DoctorApiService(dio: dioClient.dio),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              profileApiService: ProfileApiService(dio: dioClient.dio),
              tokenStorage: storage,
            ),
          ),
          BlocProvider(
            create: (context) => DoctorDashboardCubit(
              apiService: DoctorDashboardApiService(dio: dioClient.dio),
            ),
          ),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeNotifier.themeMode,
          builder: (context, mode, _) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Ehna Ma3ak',
                  themeMode: mode,
                  locale: locale,
                  supportedLocales: const [Locale('en'), Locale('ar')],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Roboto',
                    scaffoldBackgroundColor: Colors.white,
                    brightness: Brightness.light,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.black),
                      titleTextStyle:
                          TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  darkTheme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Roboto',
                    scaffoldBackgroundColor: const Color(0xFF121212),
                    brightness: Brightness.dark,
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xff0DA5FE),
                      secondary: Color(0xff0DA5FE),
                    ),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Color(0xFF121212),
                      iconTheme: IconThemeData(color: Colors.white),
                      titleTextStyle:
                          TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    textTheme: const TextTheme(
                      bodyLarge: TextStyle(color: Colors.white),
                      bodyMedium: TextStyle(color: Colors.white70),
                    ),
                  ),
                  home: const AuthWrapper(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
