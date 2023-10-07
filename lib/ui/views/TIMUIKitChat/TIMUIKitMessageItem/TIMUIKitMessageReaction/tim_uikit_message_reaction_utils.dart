import 'dart:convert';

import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/group/group_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/message/message_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';

class MessageReactionUtils {
  static final TUISelfInfoViewModel selfInfoModel =
      serviceLocator<TUISelfInfoViewModel>();
  static final MessageService _messageService =
      serviceLocator<MessageService>();

  ////////////////// 加载点击 sticker 的成员信息 //////////////////
  static final GroupServices _groupServices = serviceLocator<GroupServices>();
  static Future<String> _getGroupMemberShowName(
    String groupID,
    String memberUserID,
  ) async {
    final res = await _groupServices.getGroupMembersInfo(
      groupID: groupID,
      memberList: [memberUserID],
    );

    V2TimGroupMemberFullInfo? memberInfo;
    if (res.code == 0 && res.data != null && res.data != []) {
      memberInfo = res.data!.first;
    }
    String showName = memberUserID;
    if (memberInfo != null) {
      if (memberInfo.friendRemark != null &&
          memberInfo.friendRemark!.isNotEmpty) {
        showName = memberInfo.friendRemark!;
      } else if (memberInfo.nameCard != null &&
          memberInfo.nameCard!.isNotEmpty) {
        showName = memberInfo.nameCard!;
      } else if (memberInfo.nickName != null &&
          memberInfo.nickName!.isNotEmpty) {
        showName = memberInfo.nickName!;
      } else {
        showName = memberInfo.userID;
      }
    }

    return showName;
  }
  ////////////////// 加载点击 sticker 的成员信息 //////////////////

  static CloudCustomData getCloudCustomData(V2TimMessage message) {
    CloudCustomData messageCloudCustomData;
    try {
      messageCloudCustomData = CloudCustomData.fromJson(json.decode(
          TencentUtils.checkString(message.cloudCustomData) != null
              ? message.cloudCustomData!
              : "{}"));
    } catch (e) {
      messageCloudCustomData = CloudCustomData();
    }

    return messageCloudCustomData;
  }

  static Map<String, dynamic> getMessageReaction(V2TimMessage message) {
    return getCloudCustomData(message).messageReaction ?? {};
  }

  static Future<V2TimValueCallback<V2TimMessageChangeInfo>> clickOnSticker(
      V2TimMessage message, int sticker) async {
    final CloudCustomData messageCloudCustomData = getCloudCustomData(message);
    final Map<String, dynamic> messageReaction =
        messageCloudCustomData.messageReaction ?? {};
    List targetList = messageReaction["$sticker"] ?? [];

    ////////////////// 加载点击 sticker 的成员信息 //////////////////
    // 群组特殊处理
    if (message.groupID?.isNotEmpty == true) {
      final showName = await _getGroupMemberShowName(
        message.groupID ?? '',
        selfInfoModel.loginInfo!.userID!,
      );
      if (showName.isNotEmpty) {
        if (targetList.contains(showName)) {
          targetList.remove(showName);
        } else {
          targetList = [showName, ...targetList];
        }
      }
    } else {
      if (targetList.contains(selfInfoModel.loginInfo!.userID!)) {
        targetList.remove(selfInfoModel.loginInfo!.userID!);
      } else {
        targetList = [selfInfoModel.loginInfo!.userID!, ...targetList];
      }
    }
    ////////////////// 加载点击 sticker 的成员信息 //////////////////

    // if (targetList.contains(selfInfoModel.loginInfo!.userID!)) {
    //   targetList.remove(selfInfoModel.loginInfo!.userID!);
    // } else {
    //   targetList = [selfInfoModel.loginInfo!.userID!, ...targetList];
    // }

    messageReaction["$sticker"] = targetList;

    if (PlatformUtils().isWeb) {
      final decodedMessage = jsonDecode(message.messageFromWeb!);
      decodedMessage["cloudCustomData"] =
          jsonEncode(messageCloudCustomData.toMap());
      message.messageFromWeb = jsonEncode(decodedMessage);
    } else {
      message.cloudCustomData = json.encode(messageCloudCustomData.toMap());
    }
    return await _messageService.modifyMessage(message: message);
  }
}
