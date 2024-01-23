import 'package:flutter/widgets.dart';
import 'package:tencent_cloud_chat/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat_user_profile/widget/tencent_cloud_chat_user_profile_body.dart';

typedef UserProfileAvatarBuilder = Widget? Function(
    {required V2TimUserFullInfo userFullInfo});

typedef UserProfileContentBuilder = Widget? Function(
    {required V2TimUserFullInfo userFullInfo});

typedef UserProfileChatButtonBuilder = Widget? Function(
    {required V2TimUserFullInfo userFullInfo,
    VoidCallback? startVideoCall,
    VoidCallback? startVoiceCall});

typedef UserProfileStateButtonBuilder = Widget? Function(
    {required V2TimUserFullInfo userFullInfo});

typedef UserProfileDeleteButtonBuilder = Widget? Function(
    {required V2TimUserFullInfo userFullInfo});

class TencentCloudChatUserProfileBuilders {
  static UserProfileAvatarBuilder? _userProfileAvatarBuilder;
  static UserProfileContentBuilder? _userProfileContentBuilder;
  static UserProfileChatButtonBuilder? _userProfileChatButtonBuilder;
  static UserProfileStateButtonBuilder? _userProfileStateButtonBuilder;
  static UserProfileDeleteButtonBuilder? _userProfileDeleteButtonBuilder;

  TencentCloudChatUserProfileBuilders(
      {UserProfileAvatarBuilder? userProfileAvatarBuilder,
      UserProfileContentBuilder? userProfileContentBuilder,
      UserProfileChatButtonBuilder? userProfileChatButtonBuilder,
      UserProfileStateButtonBuilder? userProfileStateButtonBuilder,
      UserProfileDeleteButtonBuilder? userProfileDeleteButtonBuilder}) {
    _userProfileAvatarBuilder = userProfileAvatarBuilder;
    _userProfileContentBuilder = userProfileContentBuilder;
    _userProfileChatButtonBuilder = userProfileChatButtonBuilder;
    _userProfileStateButtonBuilder = userProfileStateButtonBuilder;
    _userProfileDeleteButtonBuilder = userProfileDeleteButtonBuilder;
  }

  static Widget getUserProfileAvatarBuilder(
      {required V2TimUserFullInfo userFullInfo}) {
    Widget? widget;
    if (_userProfileAvatarBuilder != null) {
      widget = _userProfileAvatarBuilder!(userFullInfo: userFullInfo);
    }
    return widget ??
        TencentCloudChatUserProfileAvatar(userFullInfo: userFullInfo);
  }

  static Widget getUserProfileContentBuilder(
      {required V2TimUserFullInfo userFullInfo}) {
    Widget? widget;
    if (_userProfileContentBuilder != null) {
      widget = _userProfileContentBuilder!(userFullInfo: userFullInfo);
    }
    return widget ??
        TencentCloudChatUserProfileContent(userFullInfo: userFullInfo);
  }

  static Widget getUserProfileChatButtonBuilder(
      {required V2TimUserFullInfo userFullInfo,
      VoidCallback? startVideoCall,
      VoidCallback? startVoiceCall}) {
    Widget? widget;
    if (_userProfileChatButtonBuilder != null) {
      widget = _userProfileChatButtonBuilder!(
          userFullInfo: userFullInfo,
          startVideoCall: startVideoCall,
          startVoiceCall: startVoiceCall);
    }
    return widget ??
        TencentCloudChatUserProfileChatButton(
          userFullInfo: userFullInfo,
          startVideoCall: startVideoCall,
          startVoiceCall: startVoiceCall,
        );
  }

  static Widget getUserProfileStateButtonBuilder(
      {required V2TimUserFullInfo userFullInfo}) {
    Widget? widget;
    if (_userProfileStateButtonBuilder != null) {
      widget = _userProfileStateButtonBuilder!(userFullInfo: userFullInfo);
    }
    return widget ??
        TencentCloudChatUserProfileStateButton(userFullInfo: userFullInfo);
  }

  static Widget getUserProfileDeleteButtonBuilder(
      {required V2TimUserFullInfo userFullInfo}) {
    Widget? widget;
    if (_userProfileDeleteButtonBuilder != null) {
      widget = _userProfileDeleteButtonBuilder!(userFullInfo: userFullInfo);
    }
    return widget ??
        TencentCloudChatUserProfileDeleteButton(userFullInfo: userFullInfo);
  }
}
