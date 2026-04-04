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
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get changePassword => translate('change_password');
  String get update => translate('update');

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

  String get notificationsTitle => translate('notifications_title');
  String get clearAll => translate('clear_all');
  String get clearAllNotifications => translate('clear_all_notifications');
  String get clearAllConfirm => translate('clear_all_confirm');
  String get failedToLoadNotifications => translate('failed_to_load_notifications');
  String get checkConnection => translate('check_connection');
  String get noNotifications => translate('no_notifications');
  String get noNotificationsSubtitle => translate('no_notifications_subtitle');
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
