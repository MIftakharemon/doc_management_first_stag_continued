part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const WELCOME = _Paths.WELCOME;
  static const SIGNIN = _Paths.SIGNIN;
  static const OTP = _Paths.OTP;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const DOCUMENTS = _Paths.DOCUMENTS;
  static const FOLDERS = _Paths.FOLDERS;
  static const SEARCH = _Paths.SEARCH;
  static const SETTINGS = _Paths.SETTINGS;
  static const DOCUMENT_DETAIL = _Paths.DOCUMENT_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const WELCOME = '/welcome';
  static const SIGNIN = '/signin';
  static const OTP = '/otp';
  static const DASHBOARD = '/dashboard';
  static const DOCUMENTS = '/documents';
  static const FOLDERS = '/folders';
  static const SEARCH = '/search';
  static const SETTINGS = '/settings';
  static const DOCUMENT_DETAIL = '/document-detail';
}
