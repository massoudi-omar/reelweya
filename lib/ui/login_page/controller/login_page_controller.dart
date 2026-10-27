import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:story_box/deep_link/share_manager/pure_flutter_share_service.dart';
import 'package:story_box/routes/app_routes.dart';
import 'package:story_box/ui/login_page/api/login_api.dart';
import 'package:story_box/ui/login_page/model/login_user_model.dart';
import 'package:story_box/ui/login_page/widget/login_page_widget.dart';

import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/custom_progress_dialog.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/preference.dart';
import 'package:story_box/utils/utils.dart';

// class LoginPageController extends GetxController {
//   LoginUserModel? loginUserModel;
//   PhoneController mobileController = PhoneController(initialValue: PhoneNumber(isoCode: IsoCode.IN, nsn: ''));
//   TextEditingController otpController = TextEditingController(text: "");
//   int loginType = 1;
//   String countryCode = "+91";
//   @override
//   void onInit() async {
//     /// FCM Token
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//
//     /// Device Id
//     final identity = await MobileDeviceIdentifier().getDeviceId();
//     Utils.showLog("Device Id => $identity");
//     Utils.showLog("FCM Token => $fcmToken");
//     log("FCM Token => $fcmToken");
//     log("identity => $identity");
//
//     if (identity != null && fcmToken != null) {
//       Preference.onSetFcmToken(fcmToken);
//       Preference.onSetIdentity(identity);
//     }
//     super.onInit();
//   }
//
//   Future<void> updateLoginType(int type) async {
//     loginType = type;
//
//     update([Constant.onLoginType]);
//   }
//
//   ///new
//
//   Future<void> onGoogleLogin() async {
//     try {
//       // Show loader
//       Get.dialog(const CustomProgressDialog());
//
//       UserCredential? userCredential = await signInWithGoogle();
//
//       if (userCredential?.user?.email != null) {
//         loginUserModel = await LoginApi.callApi(
//           loginType: Utils.getLoginTypeValue(LoginType.GOOGLE),
//           email: userCredential?.user?.email ?? "",
//           identity: Preference.identity,
//           fcmToken: Preference.fcmToken,
//           name: userCredential?.user?.displayName ?? "",
//           profilePic: userCredential?.user?.photoURL ?? '',
//         );
//
//         if (loginUserModel != null) {
//           if (loginUserModel?.status == true) {
//             // Success - proceed with login
//             String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
//             await Preference.shared.setString(Preference.userData, loginUserJson);
//             await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
//             await Preference.onIsLogin(true);
//             Get.offAllNamed(AppRoutes.bottomBarPage);
//             log("message UserID :: ${Preference.userId}");
//           } else {
//             // API returned failure - clean up Google session
//             await _cleanupGoogleSession();
//             Utils.showToast(Get.context!, loginUserModel?.message ?? "");
//           }
//         } else {
//           // API call failed - clean up Google session
//           await _cleanupGoogleSession();
//           Utils.showToast(Get.context!, EnumLocal.txtLoginFailedPleaseTryAgain.name.tr);
//         }
//       } else {
//         Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
//         Utils.showLog("Google Login Failed !!");
//       }
//     } catch (e) {
//       // Any error - clean up Google session
//       await _cleanupGoogleSession();
//       log("Error in Google Login: $e");
//       Utils.showToast(Get.context!, EnumLocal.txtAnErrorOccurredDuringLogin.name.tr);
//     } finally {
//       // Dismiss the loader
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
//
//   Future<void> _cleanupGoogleSession() async {
//     try {
//       await GoogleSignIn().signOut();
//       await FirebaseAuth.instance.signOut();
//       Utils.showLog("Google session cleaned up");
//     } catch (e) {
//       Utils.showLog("Error cleaning up Google session: $e");
//     }
//   }
//
//   onGuestLogin() async {
//     try {
//       Get.dialog(const CustomProgressDialog());
//       loginUserModel = await LoginApi.callApi(
//         loginType: Utils.getLoginTypeValue(LoginType.QUICK),
//         email: Preference.identity,
//         identity: Preference.identity,
//         fcmToken: Preference.fcmToken,
//         name: "Guest",
//       );
//
//       if (loginUserModel != null) {
//         if (loginUserModel?.status == true) {
//           String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
//           await Preference.shared.setString(Preference.userData, loginUserJson);
//           await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
//           await Preference.onIsLogin(true);
//           Get.offAllNamed(AppRoutes.bottomBarPage);
//           log("message UserID :: ${Preference.userId}");
//         } else {
//           Utils.showToast(Get.context!, loginUserModel?.message ?? "");
//         }
//       }
//       String? userDataJson = Preference.shared.getString(Preference.userData);
//       if (userDataJson != null) {
//         Map<String, dynamic> userMap = jsonDecode(userDataJson);
//         LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
//         // Use the loginUserModel as needed
//         log("loginUserModel :: ${loginUserModel.toJson()}");
//       }
//     } finally {
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
//
//   loginWithApple() async {
//     try {
//       Get.dialog(const CustomProgressDialog());
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );
//
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: appleCredential.identityToken,
//         accessToken: appleCredential.authorizationCode,
//       );
//       var auth = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//       final user = auth.user;
//       log("oauthCredential :: $oauthCredential");
//       log("user :: $user");
//       if (user != null) {
//         ///=====CALL API======///
//         loginUserModel = await LoginApi.callApi(
//           loginType: Utils.getLoginTypeValue(LoginType.APPLE),
//           email: user.email ?? "",
//           identity: Preference.identity,
//           fcmToken: Preference.fcmToken,
//           name: user.email ?? "",
//           profilePic: user.photoURL ?? '',
//         );
//         if (loginUserModel != null) {
//           String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
//           await Preference.shared.setString(Preference.userData, loginUserJson);
//           await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
//           await Preference.onIsLogin(true);
//           Get.offAllNamed(AppRoutes.bottomBarPage);
//           log("message UserID :: ${Preference.userId}");
//         } else {
//           Utils.showToast(Get.context!, loginUserModel?.message ?? "");
//         }
//         String? userDataJson = Preference.shared.getString(Preference.userData);
//         if (userDataJson != null) {
//           Map<String, dynamic> userMap = jsonDecode(userDataJson);
//           LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
//           // Use the loginUserModel as needed
//           log("loginUserModel :: ${loginUserModel.toJson()}");
//         }
//       }
//     } catch (e) {
//       Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
//       log(" $e");
//     } finally {
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
//
//   bool isExpire = false;
//   bool isLoading = false;
//   String verificationId = "";
//
//   Future<void> onVerify() async {
//     final String phoneNumber = "$countryCode${mobileController.value.nsn.trim()}";
//     Utils.showLog("onVerify Mobile Number => ${mobileController.value.nsn}");
//     Utils.showLog("onVerify Mobile Number => ${phoneNumber}");
//     FocusManager.instance.primaryFocus?.unfocus();
//
//     Utils.showLog("Mobile Number => ${mobileController.value.nsn}");
//     Utils.showLog("onVerify Mobile Number isExpire => ${isExpire}");
//
//     if (mobileController.value.nsn.trim().isEmpty) {
//       Utils.showToast(
//         Get.context!,
//         EnumLocal.txtPleaseEnterMobileNumber.name.tr,
//       );
//     } else {
//       if (isExpire) {
//         Utils.showToast(
//           Get.context!,
//           EnumLocal.txtVerificationFailedDueToMultipleAttempts.name.tr,
//         );
//         return;
//       } else {
//         isExpire = true;
//         update();
//       }
//       final String phoneNumber = "$countryCode${mobileController.value.nsn.trim()}";
//
//       try {
//         isLoading = true;
//         Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
//
//         await FirebaseAuth.instance.verifyPhoneNumber(
//           phoneNumber: phoneNumber,
//           timeout: Duration(seconds: 30),
//           verificationCompleted: (PhoneAuthCredential credential) {
//             Utils.showLog("Verification Complete");
//           },
//           verificationFailed: (FirebaseAuthException e) {
//             if (e.code == "invalid-phone-number") {
//               Utils.showToast(
//                 Get.context!,
//                 EnumLocal.txtPleaseEnterCorrectMobileNumber.name.tr,
//               );
//             } else {
//               Utils.showLog("Verification Mobile Number Failed => $e");
//               Utils.showToast(Get.context!, e.message ?? "");
//             }
//
//             if (isLoading) {
//               Get.back(); // Start Loading...
//               isLoading = false;
//               isExpire = false;
//               update();
//               Utils.showLog("Verification Failed => $e");
//             }
//           },
//           codeSent: (String verificationId, int? resendToken) {
//             this.verificationId = verificationId;
//
//             Utils.showToast(
//               Get.context!,
//               EnumLocal.txtVerificationCodeSend.name.tr,
//             );
//
//             if (isLoading) {
//               Get.back(); // Start Loading...
//               isLoading = false;
//               Utils.showLog("Verification Id => ${this.verificationId}");
//             }
//             startOtpTimer();
//             showLoginOTPBottomSheet(Get.context!);
//             // Get.toNamed(AppRoutes.verificationOtpPage, arguments: {"phoneNumber": phoneNumber, "verificationId": verificationId});
//           },
//           codeAutoRetrievalTimeout: (String verificationId) {
//             if (isLoading) {
//               Get.back(); // Start Loading...
//               isLoading = false;
//               isExpire = false;
//               update();
//               Utils.showLog("Time Out Otp => $verificationId");
//               Utils.showToast(Get.context!, EnumLocal.txtVerificationTimeout.name.tr);
//             } else {
//               isExpire = false;
//               update();
//               Utils.showLog("Time Out Otp => $verificationId");
//             }
//           },
//         );
//       } catch (e) {
//         if (isLoading) {
//           Get.back(); // Start Loading...
//           isLoading = false;
//           Utils.showLog("Verification Mobile Number Failed => $e");
//         }
//       }
//     }
//   }
//
//
//
//   Future<void> onClickSubmit() async {
//     FocusManager.instance.primaryFocus?.unfocus();
//
//     Utils.showLog("Enter Otp => ${otpController.text}");
//
//     if (otpController.text.trim().isEmpty) {
//       Utils.showToast(
//         Get.context!,
//         EnumLocal.txtPleaseEnterVerificationCode.name.tr,
//       );
//     } else {
//       final String phoneNumber = verificationId;
//
//       Utils.showLog("Mobile Number => $phoneNumber");
//
//       try {
//         Get.dialog(LoadingWidget(), barrierDismissible: false); // Start Loading...
//
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text.trim());
//         UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//
//         Utils.showLog("Verification Success => ${userCredential.user?.uid}");
//
//         Get.back(); // Start Loading...
//
//         onMobileLogin();
//       } on FirebaseAuthException catch (e) {
//         if (e.code == "invalid-verification-code") {
//           Utils.showToast(
//             Get.context!,
//             "Invalid Verification Code",
//           );
//         } else if (e.code == "session-expired") {
//           Utils.showToast(
//             Get.context!,
//             e.message ?? "",
//           );
//         } else {
//           Utils.showToast(
//             Get.context!,
//             EnumLocal.txtSomeThingWentWrong.name.tr,
//           );
//         }
//
//         Get.back(); // Start Loading...
//       }
//     }
//   }
//
//   Future<void> onMobileLogin() async {
//     Get.dialog(const CustomProgressDialog());
//     loginUserModel = await LoginApi.callApi(
//       loginType: Utils.getLoginTypeValue(LoginType.MOBILE_NUMBER),
//       email: Preference.identity,
//       identity: Preference.identity,
//       fcmToken: Preference.fcmToken,
//       mobileNumber: mobileController.value.international,
//       name: "Guest",
//     );
//
//     Get.back(); // Stop Loading...
//
//     if (loginUserModel != null) {
//       String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
//       await Preference.shared.setString(Preference.userData, loginUserJson);
//       await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
//       await Preference.onIsLogin(true);
//       Get.offAllNamed(AppRoutes.bottomBarPage);
//       log("message UserID :: ${Preference.userId}");
//     } else {
//       Utils.showToast(Get.context!, loginUserModel?.message ?? "");
//     }
//     String? userDataJson = Preference.shared.getString(Preference.userData);
//     if (userDataJson != null) {
//       Map<String, dynamic> userMap = jsonDecode(userDataJson);
//       LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
//       // Use the loginUserModel as needed
//       log("loginUserModel :: ${loginUserModel.toJson()}");
//     }
//   }
//
//   var isOtpLoading = false.obs;
//   var hasOtpError = false.obs;
//   var otpErrorMessage = ''.obs;
//   var resendTimer = 30.obs;
//   var canResendOtp = false.obs;
//
//   Timer? _timer;
//
//   void startOtpTimer() {
//     canResendOtp.value = false;
//     resendTimer.value = 30;
//
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendTimer.value > 0) {
//         resendTimer.value--;
//       } else {
//         canResendOtp.value = true;
//         timer.cancel();
//       }
//       Utils.showLog("Calling alogcat ");
//       update([Constant.onOtpUpdate]);
//     });
//   }
//
//   void resendOtp() {
//     if (!canResendOtp.value) return;
//
//     // Reset everything
//     otpController.clear();
//     hasOtpError.value = false;
//     otpErrorMessage.value = '';
//
//     // Call your API to resend OTP here
//     // await ApiService.resendOtp(phone);
//
//     startOtpTimer(); // Restart 30s timer
//
//     Utils.showToast(
//       Get.context!,
//       "New OTP has been sent to your phone",
//     );
//     // Get.snackbar(
//     //   "OTP Sent",
//     //   "New OTP has been sent to your phone",
//     //   backgroundColor: Colors.blue,
//     //   colorText: Colors.white,
//     //   snackPosition: SnackPosition.TOP,
//     // );
//   }
//
//   void clearOtpError() {
//     hasOtpError.value = false;
//     otpErrorMessage.value = '';
//   }
//
//   @override
//   void onClose() {
//     _timer?.cancel();
//     // otpController.dispose();
//     super.onClose();
//   }
//
//   static Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Sign out first to ensure account selection dialog appears
//       await GoogleSignIn().signOut();
//
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//       if (googleUser == null) {
//         // User canceled the sign-in
//         Utils.showLog("Google Sign-In canceled by user");
//         return null;
//       }
//
//       final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
//       final result = await FirebaseAuth.instance.signInWithCredential(credential);
//
//       Utils.showLog("Google Login Email => ${result.user?.email}");
//       Utils.showLog("Google Login isNewUser => ${result.additionalUserInfo?.isNewUser}");
//
//       return result;
//     } catch (error) {
//       Utils.showLog("Google Login Error => $error");
//       return null;
//     }
//   }
// }

class LoginPageController extends GetxController {
  LoginUserModel? loginUserModel;
  PhoneController mobileController = PhoneController(
    initialValue: PhoneNumber(isoCode: IsoCode.TN, nsn: ''),
  );
  TextEditingController otpController = TextEditingController(text: "");

  int loginType = 1;
  String countryCode = "+216";
  bool isExpire = false;
  bool isLoading = false;
  bool _isProcessingLogin = false;
  String verificationId = "";

  var isOtpLoading = false.obs;
  var hasOtpError = false.obs;
  var otpErrorMessage = ''.obs;
  var resendTimer = 30.obs;
  var canResendOtp = false.obs;
  Timer? _timer;

  @override
  void onInit() async {
    /// FCM Token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    /// Device Id
    final identity = await MobileDeviceIdentifier().getDeviceId();

    Utils.showLog("Device Id => $identity");
    Utils.showLog("FCM Token => $fcmToken");
    log("FCM Token => $fcmToken");
    log("identity => $identity");

    if (identity != null && fcmToken != null) {
      Preference.onSetFcmToken(fcmToken);
      Preference.onSetIdentity(identity);
    }

    super.onInit();
  }

  Future<void> updateLoginType(int type) async {
    loginType = type;
    update([Constant.onLoginType]);
  }


/// Google Login
Future<void> onGoogleLogin() async {
  try {
    log("========== STEP 1: GOOGLE LOGIN START ==========");

    Get.dialog(const CustomProgressDialog());

    log("========== STEP 2: CALLING signInWithGoogle() ==========");

    UserCredential? userCredential = await signInWithGoogle();

    log("========== STEP 3: signInWithGoogle() RETURNED ==========");
    log("userCredential: $userCredential");
    log("user: ${userCredential?.user}");
    log("email: ${userCredential?.user?.email}");

    if (userCredential?.user?.email != null) {
      log("========== STEP 4: EMAIL EXISTS ==========");
      log("Email: ${userCredential?.user?.email}");
      log("Name: ${userCredential?.user?.displayName}");
      log("Calling LoginApi...");

      log("========== STEP 5: BEFORE LoginApi.callApi() ==========");

      loginUserModel = await LoginApi.callApi(
        loginType: Utils.getLoginTypeValue(LoginType.GOOGLE),
        email: userCredential?.user?.email ?? "",
        identity: Preference.identity,
        fcmToken: Preference.fcmToken,
        name: userCredential?.user?.displayName ?? "",
        profilePic: userCredential?.user?.photoURL ?? '',
      );

      log("========== STEP 6: LoginApi.callApi() RETURNED ==========");
      log("loginUserModel: $loginUserModel");
      log("status: ${loginUserModel?.status}");
      log("message: ${loginUserModel?.message}");

      if (loginUserModel != null) {
        if (loginUserModel?.status == true) {
          log("========== STEP 7: BACKEND LOGIN SUCCESS ==========");

          String loginUserJson =
              jsonEncode(loginUserModel?.user?.toJson());

          await Preference.shared
              .setString(Preference.userData, loginUserJson);

          await Preference.onSetUserID(
              loginUserModel?.user?.id ?? "");

          await Preference.onIsLogin(true);

          Get.offAllNamed(AppRoutes.bottomBarPage);

          log("UserID: ${Preference.userId}");
        } else {
          log("========== STEP 7: BACKEND LOGIN FAILED ==========");
          log("Backend message: ${loginUserModel?.message}");

          await _cleanupGoogleSession();

          Utils.showToast(
            Get.context!,
            loginUserModel?.message ?? "",
          );
        }
      } else {
        log("========== STEP 7: LoginUserModel IS NULL ==========");

        await _cleanupGoogleSession();

        Utils.showToast(
          Get.context!,
          EnumLocal.txtLoginFailedPleaseTryAgain.name.tr,
        );
      }
    } else {
      log("========== STEP 4: NO GOOGLE EMAIL ==========");

      Utils.showToast(
        Get.context!,
        EnumLocal.txtSomeThingWentWrong.name.tr,
      );

      Utils.showLog("Google Login Failed !!");
    }
  } catch (e, stackTrace) {
    log("========== GOOGLE LOGIN EXCEPTION ==========");
    log("ERROR: $e");
    log("STACK TRACE: $stackTrace");

    await _cleanupGoogleSession();

    Utils.showToast(
      Get.context!,
      EnumLocal.txtAnErrorOccurredDuringLogin.name.tr,
    );
  } finally {
    log("========== GOOGLE LOGIN FINISHED ==========");

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}


  Future<void> _cleanupGoogleSession() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Utils.showLog("Google session cleaned up");
    } catch (e) {
      Utils.showLog("Error cleaning up Google session: $e");
    }
  }

  /// Guest Login
  onGuestLogin() async {
    try {
      Get.dialog(const CustomProgressDialog());

      loginUserModel = await LoginApi.callApi(
        loginType: Utils.getLoginTypeValue(LoginType.QUICK),
        email: Preference.identity,
        identity: Preference.identity,
        fcmToken: Preference.fcmToken,
        name: "Guest",
      );

      if (loginUserModel != null) {
        if (loginUserModel?.status == true) {
          String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
          await Preference.shared.setString(Preference.userData, loginUserJson);
          await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
          await Preference.onIsLogin(true);
          Get.offAllNamed(AppRoutes.bottomBarPage);
          log("message UserID :: ${Preference.userId}");
        } else {
          Utils.showToast(Get.context!, loginUserModel?.message ?? "");
        }
      }

      String? userDataJson = Preference.shared.getString(Preference.userData);
      if (userDataJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userDataJson);
        LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
        log("loginUserModel :: ${loginUserModel.toJson()}");
      }
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Apple Login
  loginWithApple() async {
    try {
      Get.dialog(const CustomProgressDialog());

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      var auth =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = auth.user;

      log("oauthCredential :: $oauthCredential");
      log("user :: $user");

      if (user != null) {
        loginUserModel = await LoginApi.callApi(
          loginType: Utils.getLoginTypeValue(LoginType.APPLE),
          email: user.email ?? "",
          identity: Preference.identity,
          fcmToken: Preference.fcmToken,
          name: user.email ?? "",
          profilePic: user.photoURL ?? '',
        );

        if (loginUserModel != null) {
          String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
          await Preference.shared.setString(Preference.userData, loginUserJson);
          await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
          await Preference.onIsLogin(true);
          Get.offAllNamed(AppRoutes.bottomBarPage);
          log("message UserID :: ${Preference.userId}");
        } else {
          Utils.showToast(Get.context!, loginUserModel?.message ?? "");
        }

        String? userDataJson = Preference.shared.getString(Preference.userData);
        if (userDataJson != null) {
          Map<String, dynamic> userMap = jsonDecode(userDataJson);
          LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
          log("loginUserModel :: ${loginUserModel.toJson()}");
        }
      }
    } catch (e) {
      Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
      log("Apple Login Error: $e");
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Phone Number Verification - FIXED FOR iOS
  Future<void> onVerify() async {
    final String phoneNumber =
        "$countryCode${mobileController.value.nsn.trim()}";

    Utils.showLog("onVerify Mobile Number => ${mobileController.value.nsn}");
    Utils.showLog("onVerify Mobile Number => $phoneNumber");

    FocusManager.instance.primaryFocus?.unfocus();

    if (mobileController.value.nsn.trim().isEmpty) {
      Utils.showToast(
          Get.context!, EnumLocal.txtPleaseEnterMobileNumber.name.tr);
      return;
    }

    if (isExpire) {
      Utils.showToast(Get.context!,
          EnumLocal.txtVerificationFailedDueToMultipleAttempts.name.tr);
      return;
    }

    isExpire = true;
    update();

    try {
      isLoading = true;
      Get.dialog(const LoadingWidget(), barrierDismissible: false);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 30),

        // iOS auto-verification callback - CRITICAL FIX
        verificationCompleted: (PhoneAuthCredential credential) async {
          Utils.showLog("Verification Auto-Complete (iOS)");

          try {
            // Auto sign-in with credential
            await FirebaseAuth.instance.signInWithCredential(credential);

            if (isLoading) {
              Get.back(); // Close loading dialog
              isLoading = false;
            }

            // IMPORTANT: Don't show OTP dialog, directly login
            await onMobileLogin();
          } catch (e) {
            Utils.showLog("Auto verification failed: $e");

            if (isLoading) {
              Get.back();
              isLoading = false;
            }

            // Fall back to manual OTP entry
            startOtpTimer();
            showLoginOTPBottomSheet(Get.context!);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (e.code == "invalid-phone-number") {
            Utils.showToast(Get.context!,
                EnumLocal.txtPleaseEnterCorrectMobileNumber.name.tr);
          } else {
            Utils.showLog("Verification Mobile Number Failed => $e");
            Utils.showToast(Get.context!, e.message ?? "");
          }

          if (isLoading) {
            Get.back();
            isLoading = false;
            isExpire = false;
            update();
            Utils.showLog("Verification Failed => $e");
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          Utils.showToast(
              Get.context!, EnumLocal.txtVerificationCodeSend.name.tr);

          if (isLoading) {
            Get.back();
            isLoading = false;
            Utils.showLog("Verification Id => ${this.verificationId}");
          }

          startOtpTimer();
          showLoginOTPBottomSheet(Get.context!);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          if (isLoading) {
            Get.back();
            isLoading = false;
            isExpire = false;
            update();
            Utils.showLog("Time Out Otp => $verificationId");
            Utils.showToast(
                Get.context!, EnumLocal.txtVerificationTimeout.name.tr);
          } else {
            isExpire = false;
            update();
            Utils.showLog("Time Out Otp => $verificationId");
          }
        },
      );
    } catch (e) {
      if (isLoading) {
        Get.back();
        isLoading = false;
        Utils.showLog("Verification Mobile Number Failed => $e");
      }
    }
  }

  /// Submit OTP
  Future<void> onClickSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Utils.showLog("Enter Otp => ${otpController.text}");

    if (otpController.text.trim().isEmpty) {
      Utils.showToast(
          Get.context!, EnumLocal.txtPleaseEnterVerificationCode.name.tr);
      return;
    }

    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Utils.showLog("Verification Success => ${userCredential.user?.uid}");

      Get.back(); // Close loading

      await onMobileLogin();
      otpController.clear();
      mobileController = PhoneController(
          initialValue: PhoneNumber(isoCode: IsoCode.IN, nsn: ""));
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {
        Utils.showToast(Get.context!, "Invalid Verification Code");
      } else if (e.code == "session-expired") {
        Utils.showToast(Get.context!, e.message ?? "");
      } else {
        Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
      }

      Get.back(); // Close loading
    }
  }

  /// Mobile Login API Call - FIXED to prevent double navigation
  Future<void> onMobileLogin() async {
    if (_isProcessingLogin) {
      Utils.showLog("Login already in progress, skipping...");
      return;
    }

    _isProcessingLogin = true;

    try {
      Get.dialog(const CustomProgressDialog());

      loginUserModel = await LoginApi.callApi(
        loginType: Utils.getLoginTypeValue(LoginType.MOBILE_NUMBER),
        email: Preference.identity,
        identity: Preference.identity,
        fcmToken: Preference.fcmToken,
        mobileNumber: mobileController.value.international,
        name: "Guest",
      );

      Get.back(); // Stop Loading

      if (loginUserModel != null && loginUserModel?.status == true) {
        String loginUserJson = jsonEncode(loginUserModel?.user?.toJson());
        await Preference.shared.setString(Preference.userData, loginUserJson);
        await Preference.onSetUserID(loginUserModel?.user?.id ?? "");
        await Preference.onIsLogin(true);

        // Close OTP bottom sheet if open
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }

        Get.offAllNamed(AppRoutes.bottomBarPage);
        log("message UserID :: ${Preference.userId}");
      } else {
        Utils.showToast(Get.context!, loginUserModel?.message ?? "");
      }

      String? userDataJson = Preference.shared.getString(Preference.userData);
      if (userDataJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userDataJson);
        LoginUserModel loginUserModel = LoginUserModel.fromJson(userMap);
        log("loginUserModel :: ${loginUserModel.toJson()}");
      }
    } catch (e) {
      Utils.showLog("Mobile login error: $e");
      Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
    } finally {
      _isProcessingLogin = false;

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// OTP Timer Management
  void startOtpTimer() {
    canResendOtp.value = false;
    resendTimer.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }

      Utils.showLog("OTP Timer: ${resendTimer.value}");
      update([Constant.onOtpUpdate]);
    });
  }

  void resendOtp() {
    if (!canResendOtp.value) return;

    // Reset everything
    otpController.clear();
    hasOtpError.value = false;
    otpErrorMessage.value = '';
    isExpire = false;

    // Trigger verification again
    onVerify();

    Utils.showToast(Get.context!, "New OTP has been sent to your phone");
  }

  void clearOtpError() {
    hasOtpError.value = false;
    otpErrorMessage.value = '';
  }

  /// Google Sign In Helper
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to ensure account selection dialog appears
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Utils.showLog("Google Sign-In canceled by user");
        return null;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Utils.showLog("Google Login Email => ${result.user?.email}");
      Utils.showLog(
          "Google Login isNewUser => ${result.additionalUserInfo?.isNewUser}");

      return result;
    } catch (error) {
      Utils.showLog("Google Login Error => $error");
      return null;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();

    super.onClose();
  }
}
