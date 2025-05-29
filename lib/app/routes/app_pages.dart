import 'package:get/get.dart';
import 'package:document_manager/app/modules/auth/bindings/auth_binding.dart';
import 'package:document_manager/app/modules/auth/views/welcome_view.dart';
import 'package:document_manager/app/modules/auth/views/signin_view.dart';
import 'package:document_manager/app/modules/auth/views/otp_view.dart';
import 'package:document_manager/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:document_manager/app/modules/dashboard/views/dashboard_view.dart';
import 'package:document_manager/app/modules/documents/bindings/documents_binding.dart';
import 'package:document_manager/app/modules/documents/views/documents_view.dart';
import 'package:document_manager/app/modules/folders/bindings/folders_binding.dart';
import 'package:document_manager/app/modules/folders/views/folders_view.dart';
import 'package:document_manager/app/modules/search/bindings/search_binding.dart';
import 'package:document_manager/app/modules/search/views/search_view.dart';
import 'package:document_manager/app/modules/settings/bindings/settings_binding.dart';
import 'package:document_manager/app/modules/settings/views/settings_view.dart';
import 'package:document_manager/app/modules/document_detail/bindings/document_detail_binding.dart';
import 'package:document_manager/app/modules/document_detail/views/document_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.WELCOME;

  static final routes = [
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNIN,
      page: () => const SignInView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.DOCUMENTS,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: _Paths.FOLDERS,
      page: () => const FoldersView(),
      binding: FoldersBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DOCUMENT_DETAIL,
      page: () => const DocumentDetailView(),
      binding: DocumentDetailBinding(),
    ),
  ];
}
