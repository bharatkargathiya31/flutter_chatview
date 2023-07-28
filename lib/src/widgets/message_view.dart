/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/widgets/chat_view_inherited_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants/constants.dart';
import 'image_message_view.dart';
import 'reaction_widget.dart';
import 'text_message_view.dart';
import 'voice_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    required this.onLongPress,
    required this.isLongPressEnable,
    required this.copyMessage,
    required this.deleteMessage,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.longPressAnimationDuration,
    this.onDoubleTap,
    this.highlightColor = Colors.grey,
    this.shouldHighlight = false,
    this.highlightScale = 1.2,
    this.messageConfig,
    this.onMaxDuration,
    this.controller,
    // required this.clickCallback
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to give duration of animation when user long press on chat bubble.
  final Duration? longPressAnimationDuration;

  /// Allow user to set some action when user double tap on chat bubble.
  final MessageCallBack? onDoubleTap;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Allow user to turn on/off long press tap on chat bubble.
  final bool isLongPressEnable;

  final ChatController? controller;

  final Function(int)? onMaxDuration;

  final Function(Message message) copyMessage;

  final Function(Message message) deleteMessage;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  MessageConfiguration? get messageConfig => widget.messageConfig;

  bool get isLongPressEnable => widget.isLongPressEnable;

  @override
  void initState() {
    super.initState();
    if (isLongPressEnable) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.longPressAnimationDuration ??
            const Duration(milliseconds: 250),
        upperBound: 0.1,
        lowerBound: 0.0,
      );
      if (widget.message.status != MessageStatus.read &&
          !widget.isMessageBySender) {
        widget.inComingChatBubbleConfig?.onMessageRead?.call(widget.message);
      }
      _animationController?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController?.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //_attachOnStatusChangeListeners();
    return GestureDetector(
      //onLongPressStart: isLongPressEnable ? _onLongPressStart : null,
      // onDoubleTap: () {
      //   if (widget.onDoubleTap != null) widget.onDoubleTap!(widget.message);
      // },
      child: (() {
        if (isLongPressEnable) {
          return AnimatedBuilder(
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - _animationController!.value,
                child: _messageView,
              );
            },
            animation: _animationController!,
          );
        } else {
          return _messageView;
        }
      }()),
    );
  }

  Widget get _messageView {
    final message = widget.message.message;
    final emojiMessageConfiguration = messageConfig?.emojiMessageConfig;
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.message.reaction.reactions.isNotEmpty ? 6 : 0,
        left: 5,
        right: 5,
      ),
      child: Column(
        crossAxisAlignment: widget.isMessageBySender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // CupertinoContextMenu.builder(
          //   actions: [
          //     CupertinoContextMenuAction(
          //       trailingIcon: CupertinoIcons.doc_on_doc,
          //       onPressed: () => widget.copyMessage(widget.message),
          //       child: const Text('Copy'),
          //     ),
          //     CupertinoContextMenuAction(
          //       isDestructiveAction: true,
          //       trailingIcon: CupertinoIcons.delete,
          //       onPressed: () => widget.deleteMessage(widget.message),
          //       child: const Text('Delete'),
          //     ),
          //   ],
          //   builder: (BuildContext context, Animation<double> animation) {
          //     // final Animation<BorderRadius?> borderRadiusAnimation =
          //     //     BorderRadiusTween(
          //     //   begin: BorderRadius.circular(0.0),
          //     //   end: BorderRadius.circular(
          //     //       CupertinoContextMenu.kOpenBorderRadius),
          //     // ).animate(
          //     //   CurvedAnimation(
          //     //     parent: animation,
          //     //     curve: Interval(
          //     //       CupertinoContextMenu.animationOpensAt,
          //     //       1.0,
          //     //     ),
          //     //   ),
          //     // );
          //
          //     final Animation<Decoration> boxDecorationAnimation =
          //         DecorationTween(
          //       begin: const BoxDecoration(
          //         color: Colors.transparent,
          //         //boxShadow: <BoxShadow>[],
          //       ),
          //       end: const BoxDecoration(
          //         color: Colors.transparent,
          //         //boxShadow: CupertinoContextMenu.kEndBoxShadow,
          //       ),
          //     ).animate(
          //       CurvedAnimation(
          //         parent: animation,
          //         curve: Interval(
          //           0.0,
          //           CupertinoContextMenu.animationOpensAt,
          //         ),
          //       ),
          //     );
          //
          //     return
          GestureDetector(
            onLongPress: () => _showMenu(context),
            child: Container(
              // decoration:
              //     animation.value < CupertinoContextMenu.animationOpensAt
              //         ? boxDecorationAnimation.value
              //         : null,
              child: FittedBox(
                fit: BoxFit.none,
                child: Material(
                  type: MaterialType.transparency,
                  borderOnForeground: false,
                  child: Column(
                    children: [
                      (() {
                            if (message.isAllEmoji) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: CustomPaint(
                                  painter: CustomChatBubble(
                                      color: const Color(0xFFE6E6EA),
                                      isOwn: widget.isMessageBySender),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Padding(
                                        padding: emojiMessageConfiguration
                                                ?.padding ??
                                            const EdgeInsets.all(6),
                                        child: Transform.scale(
                                          scale: widget.shouldHighlight
                                              ? widget.highlightScale
                                              : 1.0,
                                          child: Text(
                                            message,
                                            style: emojiMessageConfiguration
                                                    ?.textStyle ??
                                                const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                      ),
                                      if (widget.message.reaction.reactions
                                          .isNotEmpty)
                                        ReactionWidget(
                                          reaction: widget.message.reaction,
                                          messageReactionConfig: messageConfig
                                              ?.messageReactionConfig,
                                          isMessageBySender:
                                              widget.isMessageBySender,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (widget.message.messageType.isImage) {
                              return ImageMessageView(
                                message: widget.message,
                                isMessageBySender: widget.isMessageBySender,
                                imageMessageConfig:
                                    messageConfig?.imageMessageConfig,
                                messageReactionConfig:
                                    messageConfig?.messageReactionConfig,
                                highlightImage: widget.shouldHighlight,
                                highlightScale: widget.highlightScale,
                              );
                            } else if (widget.message.messageType.isText) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, bottom: 5),
                                child: CustomPaint(
                                  painter: CustomChatBubble(
                                      color: const Color(0xFFE6E6EA),
                                      isOwn: widget.isMessageBySender),
                                  child: TextMessageView(
                                    inComingChatBubbleConfig:
                                        widget.inComingChatBubbleConfig,
                                    outgoingChatBubbleConfig:
                                        widget.outgoingChatBubbleConfig,
                                    isMessageBySender: widget.isMessageBySender,
                                    message: widget.message,
                                    chatBubbleMaxWidth:
                                        widget.chatBubbleMaxWidth,
                                    messageReactionConfig:
                                        messageConfig?.messageReactionConfig,
                                    highlightColor: widget.highlightColor,
                                    highlightMessage: widget.shouldHighlight,
                                  ),
                                ),
                              );
                            } else if (widget.message.messageType.isVoice) {
                              return VoiceMessageView(
                                screenWidth: MediaQuery.of(context).size.width,
                                message: widget.message,
                                config: messageConfig?.voiceMessageConfig,
                                onMaxDuration: widget.onMaxDuration,
                                isMessageBySender: widget.isMessageBySender,
                                messageReactionConfig:
                                    messageConfig?.messageReactionConfig,
                                inComingChatBubbleConfig:
                                    widget.inComingChatBubbleConfig,
                                outgoingChatBubbleConfig:
                                    widget.outgoingChatBubbleConfig,
                              );
                            } else if (widget.message.messageType.isCustom &&
                                messageConfig?.customMessageBuilder != null) {
                              return messageConfig
                                  ?.customMessageBuilder!(widget.message);
                            }
                          }()) ??
                          const SizedBox(),
                      ValueListenableBuilder(
                        valueListenable: widget.message.statusNotifier,
                        builder: (context, value, child) {
                          if (widget.isMessageBySender &&
                              widget.controller?.initialMessageList.last.id ==
                                  widget.message.id &&
                              widget.message.status == MessageStatus.read) {
                            if (ChatViewInheritedWidget.of(context)
                                    ?.featureActiveConfig
                                    .lastSeenAgoBuilderVisibility ??
                                true) {
                              return widget.outgoingChatBubbleConfig
                                      ?.receiptsWidgetConfig?.lastSeenAgoBuilder
                                      ?.call(
                                          widget.message,
                                          applicationDateFormatter(
                                              widget.message.createdAt)) ??
                                  lastSeenAgoBuilder(
                                      widget.message,
                                      applicationDateFormatter(
                                          widget.message.createdAt));
                            }
                            return const SizedBox();
                          }
                          return const SizedBox();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // child: ,

          Text(
            timeFormat(widget.message.createdAt.toString()),
            //widget.message.createdAt.toString(),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          )
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox itemBox = context.findRenderObject() as RenderBox;
    final Offset position = itemBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + itemBox.size.height,
        position.dx + itemBox.size.width,
        position.dy +
            itemBox.size.height +
            10.0, // Adjust the vertical offset as needed
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        const PopupMenuItem(
          value: PopupMenuOption.copy,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Copy',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 75,
              ),
              Icon(CupertinoIcons.doc_on_doc)
            ],
          ),
        ),
        const PopupMenuItem(
          value: PopupMenuOption.delete,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 75,
              ),
              Icon(CupertinoIcons.delete, color: Colors.red)
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == PopupMenuOption.copy) {
        widget.copyMessage(widget.message);
        // Handle copy action
        //print('Copy message: ${message.text}');
      } else if (value == PopupMenuOption.delete) {
        widget.deleteMessage(widget.message);
        // Handle delete action
        //_deleteMessage(index);
      }
    });
  }

  static String timeFormat(String dateTime) {
    DateTime currentDay = DateTime.now().toLocal(),
        givenDate = DateTime.parse(dateTime).toLocal();

    // if (DateUtils.isSameDay(currentDay, givenDate)) {
    DateTime dateTime1 =
        DateFormat("yyyy-MM-dd hh:mm:ss").parse(dateTime, true);
    return DateFormat('h:mm a').format(dateTime1.toLocal());
    // }
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    await _animationController?.forward();
    widget.onLongPress(
      details.globalPosition.dy - 120 - 64,
      details.globalPosition.dx,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

class CustomChatBubble extends CustomPainter {
  final Color color;
  final bool isOwn;

  CustomChatBubble({required this.color, required this.isOwn});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color ?? Colors.blue;

    Path paintBubbleTail() {
      late Path path;
      if (!isOwn) {
        path = Path()
          ..moveTo(14, size.height - 9)
          ..quadraticBezierTo(-2, size.height + 3, -5, size.height + 0)
          ..quadraticBezierTo(0, size.height - 3, 0, size.height - 15);
      }
      if (isOwn) {
        path = Path()
          ..moveTo(size.width - 18, size.height - 8)
          ..quadraticBezierTo(
              size.width + 4, size.height + 3, size.width + 5, size.height + 0)
          ..quadraticBezierTo(
              size.width, size.height - 1, size.width, size.height - 15);
      }
      return path;
    }

    final RRect bubbleBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(18));
    final Path bubbleTail = paintBubbleTail();

    canvas.drawRRect(bubbleBody, paint);
    canvas.drawPath(bubbleTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

enum PopupMenuOption {
  copy,
  delete,
}
