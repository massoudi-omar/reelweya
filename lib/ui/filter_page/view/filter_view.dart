import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_box/custom_widget/no_data_widget.dart';
import 'package:story_box/shimmer/category_wise_movie_shimmer_ui.dart';
import 'package:story_box/shimmer/new_release_shimmer.dart';
import 'package:story_box/ui/category_page/controller/category_controller.dart';
import 'package:story_box/ui/category_page/widget/category_widget.dart';
import 'package:story_box/ui/filter_page/controller/filter_controller.dart';
import 'package:story_box/ui/filter_page/widget/filter_widget.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/font_style.dart';

///   ------------>>>>>> New Release View <<<<<<<<<<-------------

class FilterView extends StatelessWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
// ✅ Use tag to create unique instance
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.put(FilterController(), tag: tag);

    return PopScope(
      // ✅ Use PopScope instead of WillPopScope
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          Get.delete<FilterController>(tag: tag); // ✅ Delete with tag
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.colorBlack,
        appBar: AppBar(
          leading: GestureDetector(
            child: Container(
              height: 50,
              width: 50,
              color: Colors.transparent,
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ).paddingOnly(left: 16),
            ),
            onTap: () {
              Get.delete<FilterController>(tag: tag); // ✅ Delete with tag
              Get.back();
            },
          ),
          backgroundColor: AppColor.colorBlack,
          title: Text(
            EnumLocal.txtFilterData.name.tr,
            style: AppFontStyle.styleW600(AppColor.colorWhite, 22),
          ),
          centerTitle: true,
        ),
        body: GetBuilder<FilterController>(
          tag: tag, // ✅ Use same tag
          id: Constant.onGetFilter,
          builder: (controller) {
            return SizedBox(
              height: Get.height,
              width: Get.width,
              child: controller.isLoading
                  ? const CategoryWiseGridShimmer()
                  : controller.videos.isEmpty
                      ? NoDataWidget(text: EnumLocal.nothingHereYetTxt.name.tr)
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                controller: controller.scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 250,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: controller.videos.length + (controller.hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == controller.videos.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColor.colorButtonPink,
                                      ),
                                    );
                                  }

                                  final video = controller.videos[index];
                                  return FilterItemView(filterData: video);
                                },
                              ),
                            ),
                          ],
                        ),
            );
          },
        ),
      ),
    );
  }
}
