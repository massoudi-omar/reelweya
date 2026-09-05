import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_box/ads/google_reward_ad.dart';
import 'package:story_box/deep_link/services/deep_link_services.dart';
import 'package:story_box/payment/subscription/subscription_manager.dart';
import 'package:story_box/ui/earn_reward_page/api/get_daily_reward_api.dart';
import 'package:story_box/ui/earn_reward_page/model/get_daily_reward_model.dart';
import 'package:story_box/ui/earn_reward_page/view/earn_reward_view.dart';
import 'package:story_box/ui/home_page/view/home_view.dart';
import 'package:story_box/ui/login_page/model/login_user_model.dart';
import 'package:story_box/ui/my_list/view/my_list_view.dart';
import 'package:story_box/ui/profile_page/api/profile_api.dart';
import 'package:story_box/ui/profile_page/view/profile_view.dart';
import 'package:story_box/ui/reels_page/view/reels_view.dart';
import 'package:story_box/ui/refill/view/store_view.dart';
import 'package:story_box/utils/branch_io_services.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/preference.dart';

class BottomBarController extends GetxController {
  int selectedTabIndex = 0;

  // ✅ NEW: Reactive version for GetX ever() listener
  RxInt selectedTabIndexRx = 0.obs;

  PageController pageController = PageController();
  LoginUserModel? loginUserModel;
  GetDailyRewardModel? getDailyRewardModel;
  Future<void> presentCoins() async {
    getDailyRewardModel = await GetDailyRewardApi.callApi(loginUserId: Preference.userId);
    await Preference.onSetUserCoin(getDailyRewardModel?.totalCoins ?? 0);
  }

  List bottomBarPages = [
    const HomeViewPage(),
    const ReelsView(),
    const MyListViewPage(
      isShowArrow: false,
    ),
    const EranRewardView(),
    const ProfileViewPage(),
  ];

  void onChangeBottomBar(int index) {
    if (index != selectedTabIndex) {
      selectedTabIndex = index;
      selectedTabIndexRx.value = index; // ✅ NEW: Update reactive variable
      update([Constant.idOnChangeBottomBar, Constant.idBottomBar]);
    }
  }

  @override
  void onInit() {
    log("INIT ::");
    GoogleRewardAd.loadAd();
    profileApiCall();
    presentCoins();
    DeepLinkServices.onChangeRoutes(isBottomBarRoutes: true);
    PremiumManager.instance.subscriptionStream.listen((isPremium) {
      PremiumManager.instance.hasActiveSubscription.value = isPremium;
    });
    super.onInit();
  }

  Future<void> profileApiCall() async {
    loginUserModel = await ProfileApi.callApi();
    print("call bottombar api");
  }
}
