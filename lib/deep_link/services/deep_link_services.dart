import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:story_box/deep_link/config/easy_deep_links.dart';
import 'package:story_box/routes/app_routes.dart';
import 'package:story_box/ui/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:story_box/utils/api.dart';
import 'package:story_box/utils/utils.dart';

class DeepLinkServices {
  static const String videoKey = "video";
  static const String postKey = "post";
  static const String profileKey = "profile";
  static const String referralKey = "referral";
  static const String pageRoutesKey = "pageRoutes";
  static const String movieNameKey = "movieName";
  static const String idKey = "id";
  static const String referralCodeKey = "referralCode";
  static const String episodeKey = "episode";
  static const String episodeNumberKey = "episodeNumber";
  static const String contentTypeKey = "contentType";
  static const String totalVideosKey = "totalVideos";

  static String eventId = "";
  static String eventType = "";
  static String referralCode = "";
  static String contentType = "";
  static int episodeNumber = 0;
  static int totalVideos = 0;

  static bool isNavigationComplete = false;

  // Call In Main...
  static Future<void> onInitDeepLinks() async {
    try {
      await EasyDeepLinks.initialize(EasyDeepLinkConfig(domain: ApiConstant.domain, customScheme: 'myapplication', debug: true));

      EasyDeepLinks.linkStream.listen((linkInfo) {
        Utils.showLog("✅ DEEP LINK LISTEN => ${linkInfo.queryParams[pageRoutesKey]}");

        isNavigationComplete = false;

        eventId = linkInfo.queryParams[idKey] ?? "";
        eventType = linkInfo.queryParams[pageRoutesKey] ?? "";
        referralCode = linkInfo.queryParams[referralCodeKey] ?? "";
        episodeNumber = int.tryParse(linkInfo.queryParams[referralCodeKey] ?? "0") ?? 0;
      });

      Utils.showLog("✅ DEEP LINK INITIALIZE SUCCESS");
    } catch (e) {
      Utils.showLog("❌ DEEP LINK INITIALIZE FAILED => $e");
    }
  }

  static String onGenerateLink({String? id, String? pageRoutes, int? episodeNumber, String? contentType, String? movieName}) {
    final link = EasyDeepLinks.generateLink("/share",
        {pageRoutesKey: pageRoutes ?? "", idKey: id ?? "", episodeNumberKey: (episodeNumber ?? "").toString(), movieNameKey: movieName ?? ""});

    Utils.showLog("✅ DEEP LINK GENERATE => $link");
    return link;
  }

  // Call In Bottom Bar Controller...
  static Future<void> onChangeRoutes({required bool isBottomBarRoutes}) async {
    Utils.showLog("Deep Link => EventType => $eventType => EventId => $eventId => IsBottomBar => $isBottomBarRoutes");

    if (eventType.isEmpty || eventId.isEmpty) return;

    isBottomBarRoutes ? await 500.milliseconds.delay() : await 0.milliseconds.delay();

    print("-------------- ********* ${isNavigationComplete}");

    if (!isNavigationComplete) {
      Utils.showLog("Deep Link Navigation => EventType => $eventType => EventId => $eventId => IsBottomBar => $isBottomBarRoutes");

      isNavigationComplete = true;

      navigateToEpisodeWiseReels(
        movieSeriesId: eventId,
        totalVideos: totalVideos,
        episodeNumber: episodeNumber,
        movieName: "",
        contentType: contentType,
      );
    }
  }

  static void navigateToEpisodeWiseReels({
    required String movieSeriesId,
    required int totalVideos,
    int? episodeNumber,
    String? movieName,
    String? contentType,
  }) {
    eventId = "";
    eventType = "";
    log("message>>>>>totalVideos>> $totalVideos");
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      log("navigate to EpisodeWiseReels message>>>>>totalVideos>> $totalVideos");
      if (eventType == "episode") {
        Get.toNamed(
          AppRoutes.episodeWiseReels,
          arguments: {
            "movieSeriesId": movieSeriesId,
            "totalVideos": totalVideos,
            "playIndex": episodeNumber,
          },
        );
      }
      if (eventType == "movie") {
        Get.toNamed(
          AppRoutes.episodeWiseReels,
          arguments: {
            "movieSeriesId": movieSeriesId,
            "totalVideos": totalVideos,
            "playIndex": 0,
          },
        );
      }
    });
  }
}
