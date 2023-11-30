import 'package:flutter/cupertino.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:pubnub/networking.dart';
import 'package:pubnub/pubnub.dart';
import 'package:provider/provider.dart';


class PubnubInstance {
  late PubNub pubNub;
  late Subscription _subscription;
  PubNub get instance => pubNub;
  Subscription get subscription => _subscription;
  List<ChatMessage> messages = [];
  // final appPreferences = AppPreferences();

  setSubscriptionChannel(String channel) {
    _subscription = pubNub.subscribe(channels: {channel}, withPresence: true);
    _subscription.resume();
  }

  PubnubInstance(BuildContext context){
    var dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    var uuid = dashboardProvider.uuid;
    var chatToken = dashboardProvider.chatToken;
    var subscribeKey = dashboardProvider.subscribeKey;
    var publishKey = dashboardProvider.publishKey;
    console("uuid => $uuid");
    console("chatToken => $chatToken");
    console("subscribeKey => $subscribeKey");
    console("publishKey => $publishKey");
    pubNub = PubNub(
        networking: NetworkingModule(retryPolicy: RetryPolicy.exponential()),
        defaultKeyset: Keyset(
          subscribeKey: subscribeKey,
          uuid: UUID(uuid),
          publishKey: publishKey,
        ));
    pubNub.setToken(chatToken);
  }

  Future<CountMessagesResult> getMessagesCount(
      Map<String, Timetoken> channelsWithToken) async {
    try {
      var result = await pubNub.batch.countMessages(channelsWithToken);
      return result;
    }
    catch(e) {
      console("e => $e");
      rethrow;
    }

  }

  setMemberships(List<MembershipMetadataInput> channelMetaDataList) async {
    try {
      // var userValue = CurrentUser.fromJson(await appPreferences.getData(AppPreferences.USER));d
      var userValue = HiveResources.currentUserBox?.get(OfflineResources.CURRENT_USER_RESPONSE);
      await pubNub.objects.setMemberships(channelMetaDataList,
          includeCustomFields: true,
          uuid: userValue?.sId,
          limit: 10000,
          includeChannelCustomFields: true,
          includeCount: true,
          includeChannelFields: true);  

    }
    catch (e) {
      console("ERROR WHILE SETTING MEMBERSHIPS => $e");
    }

  }

  Future<MembershipsResult> getMemberships() async { 
    // var userValue = CurrentUser
    //     .fromJson(await appPreferences.getData(AppPreferences.USER));
    var userValue = HiveResources.currentUserBox?.get(OfflineResources.CURRENT_USER_RESPONSE);
    var memberships = await pubNub.objects.getMemberships(
        limit: 10000,
        includeCount: true,
        uuid: userValue?.sId,
        includeChannelFields: true,
        includeChannelCustomFields: true,
        includeCustomFields: true); 
    return memberships;
  }

}