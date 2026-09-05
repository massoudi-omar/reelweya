import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:story_box/main.dart';
import 'package:story_box/ui/login_page/controller/login_page_controller.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/font_style.dart';

import '../view/login_page_view.dart';

void showLoginOptionsBottomSheet(BuildContext context) {
  Get.bottomSheet(
    SafeArea(
      bottom: true,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.colorBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10))),
            5.height,

            // Continue as Guest
            GetBuilder<LoginPageController>(
              builder: (controller) {
                return AppButton(
                  image: AppAsset.icFillProfile,
                  label: EnumLocal.continueWithGuest.name.tr,
                  color: Colors.transparent,
                  textColor: AppColor.colorWhite,
                  onTap: () {
                    Get.back(); // close sheet
                    controller.onGuestLogin();
                  },
                );
              },
            ),

            // Google + Apple Buttons
            Row(
              children: [
                // Google Button
                Expanded(
                  child: GetBuilder<LoginPageController>(
                    builder: (controller) {
                      return AppLoginButton(
                        textAlignCenter: Platform.isAndroid,
                        image: AppAsset.icGoogle,
                        label: Platform.isAndroid ? EnumLocal.txtSignInWithGoogle.name.tr : EnumLocal.txtGoogleLogin.name.tr,
                        color: AppColor.colorWhite.withAlpha(30),
                        textColor: AppColor.colorWhite,
                        colorBorder: AppColor.colorWhite.withAlpha(100),
                        onTap: () {
                          Get.back();
                          controller.onGoogleLogin();
                        },
                      );
                    },
                  ),
                ),
                Platform.isAndroid ? 0.width : 12.width,

                // Apple Button (iOS only)
                if (Platform.isIOS)
                  Expanded(
                    child: GetBuilder<LoginPageController>(builder: (controller) {
                      return AppLoginButton(
                        image: AppAsset.icApple,
                        label: EnumLocal.txtAppleLogin.name.tr,
                        imageBgColor: AppColor.colorWhite,
                        color: AppColor.colorWhite.withAlpha(30),
                        textColor: AppColor.colorWhite,
                        colorBorder: AppColor.colorWhite.withAlpha(100),
                        onTap: () {
                          Get.back();
                          controller.loginWithApple();
                        },
                      );
                    }),
                  ),
              ],
            ),
            8.height,
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

void showLoginOTPBottomSheet(BuildContext context) {
  Get.bottomSheet(
    const OTPBottomSheet(),
    isScrollControlled: true,
    barrierColor: AppColor.transparent,
    enableDrag: true,
    isDismissible: false,
  );
}

class OTPBottomSheet extends StatelessWidget {
  const OTPBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginPageController>(
      id: Constant.onOtpUpdate,
      builder: (controller) => Container(
        decoration: const BoxDecoration(
          color: AppColor.colorBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black26,
          //     blurRadius: 20,
          //     offset: Offset(0, -5),
          //   ),
          // ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.colorWhite.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            15.height,

            // OTP Input
            SizedBox(
              width: Get.width * 0.9,
              child: PinCodeTextField(
                animationType: AnimationType.fade,
                autoDisposeControllers: false,
                textStyle: AppFontStyle.styleW600(AppColor.colorWhite, 20),
                appContext: context,
                controller: controller.otpController,
                length: 6,
                pinTheme: PinTheme(
                  fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 3),
                  shape: PinCodeFieldShape.circle,
                  fieldHeight: 45,
                  fieldWidth: 45,
                  activeBorderWidth: 1,
                  selectedBorderWidth: 1,
                  disabledBorderWidth: 1,
                  errorBorderWidth: 1,
                  inactiveBorderWidth: 1,
                  activeFillColor: controller.hasOtpError.value ? Colors.red.shade50 : Colors.white12,
                  selectedFillColor: AppColor.colorWhite.withAlpha(35),
                  inactiveFillColor: AppColor.colorWhite.withAlpha(35),
                  activeColor: controller.hasOtpError.value ? Colors.red : AppColor.colorWhite.withAlpha(35),
                  selectedColor: AppColor.colorWhite.withAlpha(41),
                  inactiveColor: AppColor.colorWhite.withAlpha(41),
                  borderWidth: 1,
                ),
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.clearOtpError(),
              ),
            ),
            5.height,

            // Phone number display
            Text(
              "${EnumLocal.txtOTPSentTo.name.tr} ${controller.mobileController.value.international}",
              style: AppFontStyle.styleW700(AppColor.colorWhite, 14),
            ),
            10.height,

            // Resend timer

            GetBuilder<LoginPageController>(
                id: Constant.onOtpUpdate,
                builder: (context) {
                  return Column(
                    children: [
                      !controller.canResendOtp.value
                          ? Text(
                              '${EnumLocal.txtKindlyWait.name.tr} ${controller.resendTimer} ${EnumLocal.txtToResend.name.tr}',
                              style: AppFontStyle.styleW600(
                                AppColor.colorTextRed.withAlpha(159),
                                14,
                              ),
                            )
                          : Text(
                              EnumLocal.txtKindlyTapResendOTPToResend.name.tr,
                              style: AppFontStyle.styleW600(
                                AppColor.colorTextRed.withAlpha(159),
                                14,
                              ),
                            ),
                      // Error message
                      if (controller.hasOtpError.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            controller.otpErrorMessage.value,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),

                      10.height,

                      // Verify/Resend Button
                      GestureDetector(
                        onTap: () {
                          if (controller.isOtpLoading.value) return;

                          if (controller.canResendOtp.value) {
                            controller.resendOtp();
                          } else {
                            controller.onClickSubmit();
                          }
                        },
                        child: Container(
                          width: Get.width,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            gradient: AppColor.primaryGradient,
                          ),
                          child: controller.isOtpLoading.value
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    controller.canResendOtp.value ? EnumLocal.txtResendOTP.name.tr : EnumLocal.txtVerifyOTP.name.tr,
                                    style: AppFontStyle.styleW700(AppColor.colorWhite, 18),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                }),

            10.height,
          ],
        ),
      ),
    );
  }
}
