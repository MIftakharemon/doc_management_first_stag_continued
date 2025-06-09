import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:document_manager/app/routes/app_pages.dart';
import 'package:document_manager/app/data/services/theme_service.dart';
import 'package:document_manager/app/data/services/auth_service.dart';
import 'package:document_manager/app/data/providers/document_provider.dart';
import 'package:document_manager/app/data/providers/folder_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage for local storage
  await GetStorage.init();
  
  // Initialize Supabase for authentication and storage..
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Initialize global services and providers
  Get.put(ThemeService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(DocumentProvider(), permanent: true);
  Get.put(FolderProvider(), permanent: true);
  
  runApp(const DocumentManagerApp());
}

class DocumentManagerApp extends StatelessWidget {
  const DocumentManagerApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return GetMaterialApp(
      title: 'DocuVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: themeService.theme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
