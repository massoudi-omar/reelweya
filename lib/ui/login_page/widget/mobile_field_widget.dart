import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phone_form_field/phone_form_field.dart';
import 'package:story_box/ui/login_page/controller/login_page_controller.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/font_style.dart';
import 'package:story_box/utils/utils.dart';

class MobileLoginFieldUi extends StatelessWidget {
  final String hintText;
  final PhoneController controller;
  final VoidCallback? onTap;
  const MobileLoginFieldUi({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginPageController>();

    return Container(
      alignment: Alignment.center,
      child: PhoneFormField(
        controller: controller,
        cursorColor: AppColor.colorWhite,
        style: AppFontStyle.styleW600(AppColor.colorWhite, 15),
        countryButtonStyle: CountryButtonStyle(
          showIsoCode: false,
          showDropdownIcon: true,

          showDialCode: true,
          flagSize: 20,
          padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), // 👈 tight flag ↔ arrow
          textStyle: AppFontStyle.styleW600(AppColor.colorWhite, 15),
        ),
        shouldLimitLengthByCountry: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppFontStyle.styleW500(AppColor.grey, 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          counterText: "",
          errorStyle: const TextStyle(fontSize: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide(color: AppColor.borderColor.withAlpha(204)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide(color: AppColor.borderColor.withAlpha(204)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide(color: AppColor.borderColor.withAlpha(204)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide(
              color: AppColor.colorTextRed,
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide(color: AppColor.borderColor.withAlpha(204)),
          ),
          filled: true,
          fillColor: AppColor.colorWhite.withAlpha(30),
          suffixIcon: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  AppAsset.icRightArrow,
                  color: AppColor.colorWhite,
                  height: 15,
                  width: 15,
                ),
              ),
            ),
          ),
        ),
        onChanged: (phone) {
          Utils.showLog("phone --> ${phone.nsn} ${phone.isoCode} ${phone.international}");
          return loginController.countryCode = "+${phone.countryCode}";
        },
        validator: PhoneValidator.validMobile(context),
      ),
    );
  }
}
