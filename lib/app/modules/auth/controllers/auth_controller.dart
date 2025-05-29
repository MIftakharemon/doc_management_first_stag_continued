import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:document_manager/app/data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final phoneController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt resendSeconds = 30.obs;
  final RxBool canResend = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }
  
  @override
  void onClose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  
  void startResendTimer() {
    _authService.startResendTimer(resendSeconds, canResend);
  }
  
  Future<void> signIn() async {
    if (phoneController.text.isEmpty) {
      errorMessage.value = 'Please enter your phone number';
      return;
    }
    
    if (phoneController.text.length != 10) {
      errorMessage.value = 'Please enter a valid 10-digit phone number';
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      await _authService.signIn(phoneController.text);
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      print('Error in signIn: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> verifyOTP() async {
    final otp = otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      errorMessage.value = 'Please enter a valid OTP';
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      await _authService.verifyOTP(otp);
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      print('Error in verifyOTP: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void resendOTP() {
    if (canResend.value) {
      signIn();
      startResendTimer();
    }
  }
  
  void focusNextOtpField(BuildContext context, int currentIndex, String value) {
    if (value.isNotEmpty && currentIndex < 5) {
      FocusScope.of(context).nextFocus();
    }
  }
  
  void focusPreviousOtpField(BuildContext context, int currentIndex, String value) {
    if (value.isEmpty && currentIndex > 0) {
      FocusScope.of(context).previousFocus();
    }
  }
}
