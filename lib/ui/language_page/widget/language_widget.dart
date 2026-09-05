import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:story_box/main.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/font_style.dart';
import 'package:story_box/utils/api.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.callback,
  });

  final String icon;
  final String title;
  final bool isSelected;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 65,
        width: Get.width,
        decoration: BoxDecoration(
          color: AppColor.colorTextGrey.withValues(alpha: 0.05),
          border: const Border(bottom: BorderSide(color: AppColor.colorBorderGrey)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15),
        // margin: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            icon.contains('/uploads/') || icon.startsWith('http')
                ? ClipOval(
                    child: Image.network(
                      icon.startsWith('http') ? icon : ApiConstant.getBaseURL() + icon.replaceFirst(RegExp(r'^/'), ''),
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 34, height: 34, color: AppColor.colorBorderGrey, child: const Icon(Icons.language, size: 20)),
                    ),
                  )
                : Image.asset(icon, width: 34, errorBuilder: (context, error, stackTrace) => const Icon(Icons.language)),
            15.width,
            Expanded(
              child: Text(
                title,
                style: AppFontStyle.styleW700(AppColor.colorBlack, 15),
              ),
            ),
            RadioItem(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  const RadioItem({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: AppColor.transparent,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? null : AppColor.transparent,
              gradient: isSelected ? AppColor.primaryGradient : null,
            ),
            child: Container(
              height: 24,
              width: 24,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? null : AppColor.greyColor,
                border: Border.all(color: isSelected ? AppColor.colorWhite : AppColor.primaryColor.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
