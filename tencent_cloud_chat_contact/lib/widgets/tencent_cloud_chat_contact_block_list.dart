// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat/utils/tencent_cloud_chat_utils.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/builders/tencent_cloud_chat_common_builders.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
import 'package:tencent_cloud_chat_contact/tencent_cloud_chat_contact_builders.dart';
import 'package:tencent_cloud_chat_contact/widgets/tencent_cloud_chat_contact_item.dart';
import 'package:tencent_cloud_chat_contact/widgets/tencent_cloud_chat_contact_leading.dart';

class TencentCloudChatContactBlockList extends StatefulWidget {
  final List<V2TimFriendInfo> blackList;

  const TencentCloudChatContactBlockList({
    Key? key,
    required this.blackList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TencentCloudChatContactBlockListState();
}

class TencentCloudChatContactBlockListState extends TencentCloudChatState<TencentCloudChatContactBlockList> {
  @override
  Widget defaultBuilder(BuildContext context) {
    var list = widget.blackList;
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) {
        return Scaffold(
          appBar: AppBar(
            leadingWidth: getWidth(100),
            leading: const TencentCloudChatContactLeading(),
            title: Text(
              tL10n.blockList,
              style: TextStyle(fontSize: textStyle.fontsize_16, fontWeight: FontWeight.w600, color: colorTheme.contactItemFriendNameColor),
            ),
            centerTitle: true,
            backgroundColor: colorTheme.contactBackgroundColor,
          ),
          body: Container(
            color: colorTheme.contactApplicationBackgroundColor,
            padding: EdgeInsets.only(top: getHeight(9)),
            child: Center(
              child: list.isNotEmpty
                  ? ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return TencentCloudChatContactBlockListItem(friend: list[index]);
                      })
                  : Center(
                      child: Text(
                      tL10n.noBlockList,
                      style: TextStyle(
                        fontSize: textStyle.fontsize_16,
                        color: colorTheme.contactNoListColor,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget desktopBuilder(BuildContext context) {
    var list = widget.blackList;
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) {
        return Scaffold(
          body: Container(
            color: colorTheme.contactApplicationBackgroundColor,
            padding: EdgeInsets.only(top: getHeight(9)),
            child: Center(
              child: list.isNotEmpty
                  ? ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return TencentCloudChatContactBlockListItem(friend: list[index]);
                      })
                  : Center(
                      child: Text(
                      tL10n.noBlockList,
                      style: TextStyle(
                        fontSize: textStyle.fontsize_16,
                        color: colorTheme.contactNoListColor,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
            ),
          ),
        );
      },
    );
  }
}

class TencentCloudChatContactBlockListItem extends StatefulWidget {
  final V2TimFriendInfo friend;

  const TencentCloudChatContactBlockListItem({super.key, required this.friend});

  @override
  State<StatefulWidget> createState() => TencentCloudChatContactBlockListItemState();
}

class TencentCloudChatContactBlockListItemState extends TencentCloudChatState<TencentCloudChatContactBlockListItem> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: getHeight(5), horizontal: getWidth(3)),
        child: Row(
          children: [TencentCloudChatContactBuilders.getContactBlockListItemAvatarBuilder(widget.friend), TencentCloudChatContactBuilders.getContactBlockListItemContentBuilder(widget.friend)],
        ));
  }
}

class TencentCloudChatContactBlockListItemAvatar extends StatefulWidget {
  final V2TimFriendInfo friend;

  const TencentCloudChatContactBlockListItemAvatar({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TencentCloudChatContactBlockListItemAvatarState();
}

class TencentCloudChatContactBlockListItemAvatarState extends TencentCloudChatState<TencentCloudChatContactBlockListItemAvatar> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(13),
        ),
        child: TencentCloudChatCommonBuilders.getCommonAvatarBuilder(
          scene: TencentCloudChatAvatarScene.contacts,
          imageList: [TencentCloudChatUtils.checkString(widget.friend.userProfile?.faceUrl) ?? "https://comm.qq.com/im/static-files/im-demo/im_virtual_customer.png"],
          width: getSquareSize(40),
          height: getSquareSize(40),
          borderRadius: getSquareSize(58),
        ));
  }
}

class TencentCloudChatContactBlockListItemContent extends StatefulWidget {
  final V2TimFriendInfo friend;

  const TencentCloudChatContactBlockListItemContent({super.key, required this.friend});

  @override
  State<StatefulWidget> createState() => TencentCloudChatContactBlockListItemContentState();
}

class TencentCloudChatContactBlockListItemContentState extends TencentCloudChatState<TencentCloudChatContactBlockListItemContent> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatContactItemContent(friend: widget.friend);
  }
}

class TencentCloudChatContactBlockListData {
  final List<V2TimFriendInfo> blockList;

  TencentCloudChatContactBlockListData({required this.blockList});

  Map<String, dynamic> toMap() {
    return {'blockList': blockList.toString()};
  }

  static TencentCloudChatContactBlockListData fromMap(Map<String, dynamic> map) {
    return TencentCloudChatContactBlockListData(blockList: map['blockList'] as List<V2TimFriendInfo>);
  }
}
