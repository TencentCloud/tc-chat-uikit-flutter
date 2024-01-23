import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:tencent_cloud_chat/data/message/tencent_cloud_chat_message_data.dart';
import 'package:tencent_cloud_chat/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat/utils/tencent_cloud_chat_utils.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_message/tencent_cloud_chat_message_controller.dart';
import 'package:tencent_cloud_chat_message/tencent_cloud_chat_message_list_view/message_list/message_list.dart';
import 'package:tencent_cloud_chat_message/tencent_cloud_chat_message_list_view/message_list/message_list_controller.dart';
import 'package:tencent_cloud_chat_message/tencent_cloud_chat_message_list_view/message_row/tencent_cloud_chat_message_row_container.dart';

class TencentCloudChatMessageListView extends StatefulWidget {
  final String? userID;
  final String? groupID;
  final List<V2TimMessage> messageList;
  final Function({
    required TencentCloudChatMessageLoadDirection direction,
  }) loadMoreMessages;
  final Future Function() loadToLatestMessage;
  final bool haveMoreLatestData;
  final bool haveMorePreviousData;
  final TencentCloudChatMessageController controller;
  final ValueChanged<List<V2TimMessage>> onSelectMessages;
  final int? unreadCount;
  final int? c2cReadTimestamp;
  final int? groupReadSequence;
  final Function({
    V2TimMessage? message,
    int? timeStamp,
    int? seq,
  }) loadToSpecificMessage;
  final List<V2TimMessage> Function() getMessageList;
  final List<V2TimMessage> messagesMentionedMe;
  final ValueChanged<V2TimMessage> highlightMessage;

  const TencentCloudChatMessageListView({
    super.key,
    this.userID,
    this.groupID,
    required this.messageList,
    required this.loadMoreMessages,
    required this.haveMoreLatestData,
    required this.haveMorePreviousData,
    required this.loadToLatestMessage,
    required this.onSelectMessages,
    required this.controller,
    this.unreadCount,
    this.c2cReadTimestamp,
    this.groupReadSequence,
    required this.loadToSpecificMessage,
    required this.getMessageList,
    required this.messagesMentionedMe,
    required this.highlightMessage,
  }) : assert((userID == null) != (groupID == null));

  @override
  State<TencentCloudChatMessageListView> createState() =>
      _TencentCloudChatMessageListViewState();
}

class _TencentCloudChatMessageListViewState
    extends TencentCloudChatState<TencentCloudChatMessageListView> {
  final MessageListController _messageListController = MessageListController();
  late TencentCloudChatMessageController? controller;
  Key _messageListKey = UniqueKey();

  List<V2TimMessage> _messagesMentionedMe = [];

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller?.addListener(_controllerEventListener);
    _messagesMentionedMe = widget.messagesMentionedMe;
  }

  @override
  void didUpdateWidget(TencentCloudChatMessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messagesMentionedMe != oldWidget.messagesMentionedMe) {
      setState(() {
        _messagesMentionedMe = widget.messagesMentionedMe;
      });
    }

    if ((widget.userID != oldWidget.userID &&
            !(TencentCloudChatUtils.checkString(widget.userID) == null &&
                TencentCloudChatUtils.checkString(oldWidget.userID) == null)) ||
        (widget.groupID != oldWidget.groupID &&
            !(TencentCloudChatUtils.checkString(widget.groupID) == null &&
                TencentCloudChatUtils.checkString(oldWidget.groupID) ==
                    null))) {
      setState(() {
        _messageListKey = UniqueKey();
      });
    }
  }

  void _controllerEventListener() {
    final event = controller?.eventName;
    switch (event) {
      case EventName.scrollToBottom:
        _messageListController.scrollToBottom();
        break;
      default:
        break;
    }
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => MessageList(
              key: _messageListKey,
              haveMorePreviousData: widget.haveMorePreviousData,
              haveMoreLatestData: widget.haveMoreLatestData,
              offsetToTriggerLoadPrevious: 200,
              offsetToTriggerLoadLatest: 100,
              unreadMsgCount:
                  (widget.unreadCount ?? 0) > 0 ? widget.unreadCount : null,
              onLoadToLatest: widget.loadToLatestMessage,
              onLoadPreviousMsgs: () => widget.loadMoreMessages(
                  direction: TencentCloudChatMessageLoadDirection.previous),
              onLoadLatestMsgs: () => widget.loadMoreMessages(
                  direction: TencentCloudChatMessageLoadDirection.latest),
              msgCount: widget.messageList.length,
              messagesMentionedMe: _messagesMentionedMe,
              controller: _messageListController,
              determineIsLatestReadMessage: (index) {
                final message = widget.messageList[index];
                final messageKey =
                    TencentCloudChatUtils.checkString(widget.groupID) != null
                        ? int.tryParse(message.seq ?? "")
                        : message.timestamp;
                if (TencentCloudChatUtils.checkString(widget.groupID) != null) {
                  return (
                    messageKey == widget.groupReadSequence &&
                        widget.groupReadSequence != null,
                    true
                  );
                } else {
                  final previousMessageKey = widget
                          .messageList[
                              min(widget.messageList.length - 1, index + 1)]
                          .timestamp ??
                      0;
                  return (
                    (widget.c2cReadTimestamp != null) &&
                        ((widget.c2cReadTimestamp ?? 0) < (messageKey ?? 0)) &&
                        ((widget.c2cReadTimestamp ?? 0) > previousMessageKey) &&
                        (previousMessageKey < (messageKey ?? 0)),
                    false
                  );
                }
              },
              latestReadMsgKey:
                  TencentCloudChatUtils.checkString(widget.groupID) != null
                      ? widget.groupReadSequence
                      : widget.c2cReadTimestamp,
              itemBuilder: (BuildContext context, int index) {
                V2TimMessage message = widget.messageList[index];
                return TencentCloudChatMessageRowContainer(
                  messageRowWidth: constraints.maxWidth,
                  message: message,
                  isMergeMessage: false,
                );
              },
              onMsgKey: (int index) =>
                  widget.messageList[index].msgID ??
                  widget.messageList[index].id ??
                  widget.messageList[index].timestamp.toString(),
              onLoadToLatestReadMessage: () async {
                try {
                  await widget.loadToSpecificMessage(
                    timeStamp:
                        TencentCloudChatUtils.checkString(widget.userID) != null
                            ? widget.c2cReadTimestamp
                            : null,
                    seq: TencentCloudChatUtils.checkString(widget.groupID) !=
                            null
                        ? widget.groupReadSequence
                        : null,
                  );

                  final messageList = widget.getMessageList().asMap();

                  final target = messageList.entries.lastWhere((entry) {
                    final currentIndex = entry.key;
                    final message = entry.value;
                    final messageKey =
                        TencentCloudChatUtils.checkString(widget.groupID) !=
                                null
                            ? int.tryParse(message.seq ?? "")
                            : message.timestamp;
                    if (TencentCloudChatUtils.checkString(widget.groupID) !=
                        null) {
                      return (messageKey == widget.groupReadSequence &&
                          widget.groupReadSequence != null);
                    } else {
                      final previousMessageKey = messageList[
                                  min(messageList.length - 1, currentIndex + 1)]
                              ?.timestamp ??
                          0;
                      return ((widget.c2cReadTimestamp != null) &&
                          ((widget.c2cReadTimestamp ?? 0) <
                              (messageKey ?? 0)) &&
                          ((widget.c2cReadTimestamp ?? 0) >
                              previousMessageKey) &&
                          (previousMessageKey < (messageKey ?? 0)));
                    }
                  });
                  return target.key;
                } catch (e) {
                  return -1;
                }
              },
              onLoadToLatestMessageMentionedMe: () async {
                final V2TimMessage latestMessage = _messagesMentionedMe.first;
                await widget.loadToSpecificMessage(
                  message: latestMessage,
                );
                _messagesMentionedMe.removeAt(0);

                final messageList = widget.getMessageList();
                final targetIndex = messageList.lastIndexWhere((entry) {
                  final message = entry;
                  return (message.msgID == latestMessage.msgID &&
                          TencentCloudChatUtils.checkString(
                                  latestMessage.msgID) !=
                              null) ||
                      (message.id == latestMessage.id &&
                          TencentCloudChatUtils.checkString(latestMessage.id) !=
                              null);
                });
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    widget.highlightMessage(latestMessage);
                  });
                });
                return targetIndex;
              },
            ));
  }
}
