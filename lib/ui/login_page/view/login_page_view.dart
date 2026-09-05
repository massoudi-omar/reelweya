import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:story_box/custom_widget/custom_gradiant_text.dart';
import 'package:story_box/main.dart';
import 'package:story_box/ui/login_page/controller/login_page_controller.dart';
import 'package:story_box/ui/login_page/widget/login_page_widget.dart';
import 'package:story_box/ui/login_page/widget/mobile_field_widget.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/font_style.dart';
import 'package:story_box/utils/utils.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginPageController(), permanent: true);
    controller.onInit();
    return Scaffold(
      backgroundColor: AppColor.colorBlack,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: Get.width,
              height: Get.height,
              child: Image.asset(
                AppAsset.icLoginBackground,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  const Spacer(),

                  Image.asset(
                    AppAsset.appIconGradient,
                    width: 70,
                    height: 70,
                    fit: BoxFit.fill,
                  ),
                  // GetBuilder<LoginPageController>(builder: (controller) {
                  //
                  //   return  0.height  15.height
                  // },),
                  GradientText(
                    gradient: AppColor.primaryGradient,
                    text: Constant.appName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      fontFamily: Constant.appFontNuePlank,
                      height: 1,
                    ),
                  ),

                  90.height,

                  MobileLoginFieldUi(
                    hintText: EnumLocal.txtMobileNumHintTest.name.tr,
                    controller: controller.mobileController,
                    onTap: () {
                      if (controller.mobileController.value.nsn == "") {
                        Utils.showToast(Get.context!, EnumLocal.txtPleaseEnterNumber.name.tr);
                      } else if (!controller.mobileController.value.isValid()) {
                        Utils.showToast(Get.context!, EnumLocal.txtPleaseEnterValidNumber.name.tr);
                      } else {
                        controller.onVerify();
                        // showLoginOTPBottomSheet(context);
                      }
                    },
                  ),
                  15.height,
                  GestureDetector(
                    onTap: () {
                      showLoginOptionsBottomSheet(context);
                    },
                    child: Text(
                      EnumLocal.txtOrLoginUsingAnotherMethod.name.tr,
                      style: TextStyle(
                          color: AppColor.colorWhite,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontFamily: Constant.appFontFamily,
                          decorationColor: AppColor.colorWhite,
                          decorationThickness: 2),
                    ),
                  ),

                  20.height,
                  Text(
                    EnumLocal.ifYouContinueYouAgree.name.tr,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  14.height
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhoneNumberInputValidator? getValidator(BuildContext context) {
    List<PhoneNumberInputValidator> validators = [];
    if (true) {
      validators.add(PhoneValidator.validMobile(context));
    } else {
      validators.add(PhoneValidator.valid(context));
    }
    return validators.isNotEmpty ? PhoneValidator.compose(validators) : null;
  }
}

class AppLoginButton extends StatelessWidget {
  final String? image;
  final String label;
  final Color color;
  final Color colorBorder;
  final Color? textColor;
  final Color? imageBgColor;
  final bool? textAlignCenter;
  final VoidCallback onTap;

  const AppLoginButton({
    super.key,
    this.image,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = AppColor.colorWhite,
    this.colorBorder = AppColor.colorWhite,
    this.imageBgColor = AppColor.colorWhite,
    this.textAlignCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: color, // Background color of the button
              borderRadius: BorderRadius.circular(30.0), // Rounded corners
              border: Border.all(
                color: colorBorder, // Border color
                width: 1.0, // Border width
              )),
          padding: const EdgeInsets.all(6),
          width: double.infinity, // Full width buttons
          child: textAlignCenter == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(5),
                        child: image != null
                            ? Image.asset(
                                image!,
                                height: 24,
                                width: 24,
                              )
                            : const SizedBox()),
                    const SizedBox(width: 8), // Space between image and label
                    Text(
                      label,
                      style: AppFontStyle.styleW800(textColor, 16),

                      // TextStyle(
                      //   color: textColor,
                      //   fontSize: 16,
                      // ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: imageBgColor ?? AppColor.colorTextLightGrey.withAlpha(70),
                        ),
                        child: image != null ? Image.asset(image!, height: 24, width: 24) : const SizedBox()),
                    const SizedBox(width: 10), // Space between image and label
                    Text(
                      label,
                      style: AppFontStyle.styleW800(textColor, 16),

                      // TextStyle(
                      //   color: textColor,
                      //   fontSize: 16,
                      // ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String? image;
  final String label;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  const AppButton({
    super.key,
    this.image,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = AppColor.colorWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
            gradient: AppColor.primaryGradient,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          width: double.infinity, // Full width buttons
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null ? Image.asset(image!, height: 24, width: 24) : const SizedBox(),
              const SizedBox(width: 10), // Space between image and label
              Text(label, style: AppFontStyle.styleW600(textColor, 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppleGoogleButton extends StatelessWidget {
  final String? image;
  final String label;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  const AppleGoogleButton({
    super.key,
    this.image,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = AppColor.colorWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
            gradient: AppColor.primaryGradient,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          width: double.infinity, // Full width buttons
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null ? Image.asset(image!, height: 24, width: 24) : const SizedBox(),
              const SizedBox(width: 10), // Space between image and label
              Text(label, style: AppFontStyle.styleW600(textColor, 16)),
            ],
          ),
        ),
      ),
    );
  }
}
