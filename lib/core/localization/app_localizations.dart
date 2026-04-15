import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _strings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    final jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) => _strings[key] ?? key;

  // Convenience getters
  String get home => translate('home');
  String get search => translate('search');
  String get bot => translate('bot');
  String get podcasts => translate('podcasts');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get logOut => translate('log_out');
  String get nightMood => translate('night_mood');
  String get help => translate('help');
  String get myProgress => translate('my_progress');
  String get therapists => translate('therapists');
  String get resources => translate('resources');
  String get sessions => translate('sessions');
  String get patients => translate('patients');
  String get reports => translate('reports');

  String get english => translate('english');
  String get arabic => translate('arabic');
  String get selectLanguage => translate('select_language');

  String get logoutTitle => translate('logout_title');
  String get logoutSubtitle => translate('logout_subtitle');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get edit => translate('edit');
  String get editProfile => translate('edit_profile');
  String get fullName => translate('full_name');
  String get email => translate('email');
  String get name => translate('name');
  String get age => translate('age');
  String get gender => translate('gender');
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get changePassword => translate('change_password');
  String get update => translate('update');
  String get specialization => translate('specialization');
  String get experienceYears => translate('experience_years');
  String get bio => translate('bio');
  String get sessionPrice => translate('session_price');

  String get general => translate('general');
  String get security => translate('security');
  String get shareApp => translate('share_app');
  String get supportCenter => translate('support_center');
  String get support => translate('support');
  String get privacyPolicy => translate('privacy_policy');
  String get accountSettings => translate('account_settings');
  String get savedResources => translate('saved_resources');
  String get languageTrailing => translate('language_trailing');

  String get uploadingImage => translate('uploading_image');
  String get updatingProfile => translate('updating_profile');
  String get profileUpdated => translate('profile_updated');
  String get imageUpdated => translate('image_updated');
  String get passwordUpdatedSuccess => translate('password_updated_success');

  String get whatsOnYourMind => translate('whats_on_your_mind');
  String get photo => translate('photo');
  String get change => translate('change');
  String get post => translate('post');
  String get comments => translate('comments');
  String get writeAComment => translate('write_a_comment');
  String get editPost => translate('edit_post');
  String get postContent => translate('post_content');
  String get noPostsYet => translate('no_posts_yet');
  String get beFirstToShare => translate('be_first_to_share');
  String get retry => translate('retry');
  String get pleaseEnterText => translate('please_enter_text');

  String get tryAgain => translate('try_again');
  String get noName => translate('no_name');
  String get noEmail => translate('no_email');

  String get forYou => translate('for_you');
  String get following => translate('following');

  String get sessionsLabel => translate('sessions_label');
  String get exercisesLabel => translate('exercises_label');
  String get daysLabel => translate('days_label');

  String get editComment => translate('edit_comment');
  String get deleteComment => translate('delete_comment');
  String get deleteCommentConfirm => translate('delete_comment_confirm');
  String get delete => translate('delete');
  String get enterCommentText => translate('enter_comment_text');
  String get available => translate('available');
  String get reply => translate('reply');

  String get notificationsTitle => translate('notifications_title');
  String get clearAll => translate('clear_all');
  String get clearAllNotifications => translate('clear_all_notifications');
  String get clearAllConfirm => translate('clear_all_confirm');
  String get failedToLoadNotifications => translate('failed_to_load_notifications');
  String get checkConnection => translate('check_connection');
  String get noNotifications => translate('no_notifications');
  String get noNotificationsSubtitle => translate('no_notifications_subtitle');

  // Progress
  String get myProgressTitle => translate('my_progress_title');
  String get howFeelingToday => translate('how_feeling_today');
  String get moodScale => translate('mood_scale');
  String get selectedMood => translate('selected_mood');
  String get todaysMood => translate('todays_mood');
  String get closeDetails => translate('close_details');
  String get viewAssessmentDetails => translate('view_assessment_details');
  String get noProgressData => translate('no_progress_data');
  String get refresh => translate('refresh');
  String get savingMood => translate('saving_mood');
  String get helloHowFeel => translate('hello_how_feel');

  // Therapists
  String get therapistsTitle => translate('therapists_title');
  String get searchDoctor => translate('search_doctor');
  String get bookSession => translate('book_session');
  String get bookSessionWith => translate('book_session_with');
  String get sessionType => translate('session_type');
  String get sessionDate => translate('session_date');
  String get sessionTime => translate('session_time');
  String get selectDate => translate('select_date');
  String get selectTime => translate('select_time');
  String get confirmBooking => translate('confirm_booking');
  String get pleaseSelectDateTime => translate('please_select_date_time');
  String get bookingSession => translate('booking_session');
  String get noDoctorsFound => translate('no_doctors_found');
  String get years => translate('years');

  // Resources
  String get resourcesTitle => translate('resources_title');
  String get searchResources => translate('search_resources');
  String get articles => translate('articles');
  String get videos => translate('videos');
  String get downloads => translate('downloads');

  // Podcasts
  String get podcastsTitle => translate('podcasts_title');
  String get noPodcasts => translate('no_podcasts');
  String get checkBackLater => translate('check_back_later');

  // Help
  String get helpTitle => translate('help_title');
  String get faqs => translate('faqs');
  String get chatWithUs => translate('chat_with_us');
  String get callUs => translate('call_us');
  String get supportTickets => translate('support_tickets');
  String get preferEmailOrCall => translate('prefer_email_or_call');
  String get sendEmail => translate('send_email');
  String get contactSupport => translate('contact_support');
  String get createTicket => translate('create_ticket');
  String get subject => translate('subject');
  String get descriptionLabel => translate('description');
  String get submit => translate('submit');
  String get send => translate('send');
  String get messageLabel => translate('message');
  String get sendSupportEmail => translate('send_support_email');
  String get noTicketsFound => translate('no_tickets_found');
  String get findAnswers => translate('find_answers');
  String get getSupportChat => translate('get_support_chat');
  String get reachSupport => translate('reach_support');
  String get manageRequests => translate('manage_requests');

  // Saved Resources
  String get savedResourcesTitle => translate('saved_resources_title');
  String get noSavedResources => translate('no_saved_resources');

  // Sessions
  String get sessionsTitle => translate('sessions_title');
  String get add => translate('add');
  String get startSession => translate('start_session');
  String get noSessions => translate('no_sessions');
  String get clickAddSession => translate('click_add_session');
  String get serverConnectionError => translate('server_connection_error');
  String get noSessionLink => translate('no_session_link');
  String get couldNotLaunch => translate('could_not_launch');

  // Patients
  String get patientsTitle => translate('patients_title');
  String get myPatients => translate('my_patients');
  String get noPatients => translate('no_patients');
  String get lastSession => translate('last_session');
  String get view => translate('view');

  // Reports
  String get reportsTitle => translate('reports_title');
  String get noReports => translate('no_reports');

  // Add Session
  String get addSessionTitle => translate('add_session_title');
  String get patientName => translate('patient_name');
  String get enterPatientName => translate('enter_patient_name');
  String get enterPrice => translate('enter_price');
  String get price => translate('price');
  String get date => translate('date');
  String get time => translate('time');
  String get saving => translate('saving');
  String get sessionAdded => translate('session_added');
  String get requiredField => translate('required_field');

  // Messages
  String get messagesTitle => translate('messages_title');
  String get noMessages => translate('no_messages');

  // Login
  String get loginTitle => translate('login_title');
  String get emailHint => translate('email_hint');
  String get passwordHint => translate('password_hint');
  String get rememberMe => translate('remember_me');
  String get forgotPassword => translate('forgot_password');
  String get login => translate('login');
  String get noAccount => translate('no_account');
  String get createNew => translate('create_new');
  String get enterEmail => translate('enter_email');
  String get enterValidEmail => translate('enter_valid_email');
  String get enterPassword => translate('enter_password');
  String get passwordMin => translate('password_min');

  // Chatbot
  String get chatbotTitle => translate('chatbot_title');
  String get chatbotDesc => translate('chatbot_desc');
  String get getStarted => translate('get_started');
  String get askDepo => translate('ask_depo');
  String get selectImageSource => translate('select_image_source');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get copiedToClipboard => translate('copied_to_clipboard');
  String get imageReceived => translate('image_received');
  String get botReply => translate('bot_reply');

  // Search
  String get searchHint => translate('search_hint');
  String get recent => translate('recent');
  String get seeAll => translate('see_all');

  // Doctor Dashboard
  String get dashboardStats => translate('dashboard_stats');
  String get recentActivity => translate('recent_activity');
  String get medicalReports => translate('medical_reports');
  String get uploadNew => translate('upload_new');
  String get noRecentActivity => translate('no_recent_activity');
  String get noMedicalReports => translate('no_medical_reports');
  String get addPatientRecord => translate('add_patient_record');
  String get uploadMedicalReport => translate('upload_medical_report');
  String get patientId => translate('patient_id');
  String get diagnosis => translate('diagnosis');
  String get notes => translate('notes');
  String get treatmentPlan => translate('treatment_plan');
  String get reportType => translate('report_type');
  String get fileUrl => translate('file_url');
  String get upload => translate('upload');
  String get processing => translate('processing');
  String get news => translate('news');
  String get addRecord => translate('add_record');
  String get upcomingSessions => translate('upcoming_sessions');
  String get upcoming => translate('upcoming');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
