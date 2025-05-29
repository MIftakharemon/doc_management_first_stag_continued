import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:document_manager/app/routes/app_pages.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final GetStorage _box = GetStorage();
  final RxBool isLoggedIn = false.obs;
  final RxString phoneNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString userName = 'User'.obs;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void checkLoginStatus() {
    try {
      final session = _supabaseClient.auth.currentSession;
      final token = _box.read<String>('user_token');
      final name = _box.read<String>('user_name');
      
      if (session != null || token != null) {
        isLoggedIn.value = true;
        if (name != null) userName.value = name;
        
        if (Get.currentRoute != Routes.DASHBOARD) {
          Get.offAllNamed(Routes.DASHBOARD);
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> signIn(String phone) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      phoneNumber.value = phone;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      Get.toNamed(Routes.OTP);
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error in signIn: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (otp == "123456") {
        // Store user session
        _box.write('user_token', 'demo_token_${DateTime.now().millisecondsSinceEpoch}');
        _box.write('user_phone', phoneNumber.value);
        _box.write('user_name', 'Demo User');
        
        isLoggedIn.value = true;
        userName.value = 'Demo User';
        
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        errorMessage.value = 'Invalid OTP! Use 123456 for demo';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      print('Error in verifyOTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      
      _box.remove('user_token');
      _box.remove('user_phone');
      _box.remove('user_name');
      
      isLoggedIn.value = false;
      userName.value = 'User';
      
      Get.offAllNamed(Routes.WELCOME);
    } catch (e) {
      errorMessage.value = 'An error occurred during sign out.';
      print('Error signing out: $e');
    }
  }
  
  void startResendTimer(RxInt resendSeconds, RxBool canResend) {
    canResend.value = false;
    resendSeconds.value = 30;
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }
}
