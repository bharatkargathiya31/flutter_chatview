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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/models.dart';

import '../utils/constants/constants.dart';
import 'link_preview.dart';
import 'reaction_widget.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.isMessageBySender,
    required this.message,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.messageReactionConfig,
    this.highlightMessage = false,
    this.highlightColor,
    //required this.clickCallback,
  }) : super(key: key);

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides message instance of chat.
  final Message message;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents message should highlight.
  final bool highlightMessage;

  /// Allow user to set color of highlighted message.
  final Color? highlightColor;

  //final VoidCallback clickCallback;


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textMessage = message.message;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: chatBubbleMaxWidth ??
                  MediaQuery.of(context).size.width * 0.75),
          padding: _padding ??
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
          margin: _margin ??
              EdgeInsets.fromLTRB(
                  5, 0, 6, message.reaction.reactions.isNotEmpty ? 15 : 2),
          decoration: BoxDecoration(
            //color: highlightMessage ? highlightColor : _color,
            borderRadius: _borderRadius(textMessage),
          ),
          child: textMessage.isUrl
              ? LinkPreview(
                  linkPreviewConfig: _linkPreviewConfig,
                  url: textMessage,
                )
              : Text(
                  textMessage,
                  style: _textStyle ??
                      textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                ),
        ),
        if (message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            key: key,
            isMessageBySender: isMessageBySender,
            reaction: message.reaction,
            messageReactionConfig: messageReactionConfig,
          ),
      ],
    );
  }

  EdgeInsetsGeometry? get _padding => isMessageBySender
      ? outgoingChatBubbleConfig?.padding
      : inComingChatBubbleConfig?.padding;

  EdgeInsetsGeometry? get _margin => isMessageBySender
      ? outgoingChatBubbleConfig?.margin
      : inComingChatBubbleConfig?.margin;

  LinkPreviewConfiguration? get _linkPreviewConfig => isMessageBySender
      ? outgoingChatBubbleConfig?.linkPreviewConfig
      : inComingChatBubbleConfig?.linkPreviewConfig;

  TextStyle? get _textStyle => isMessageBySender
      ? outgoingChatBubbleConfig?.textStyle
      : inComingChatBubbleConfig?.textStyle;

  BorderRadiusGeometry _borderRadius(String message) => isMessageBySender
      ? outgoingChatBubbleConfig?.borderRadius ??
          (message.length < 37
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2))
      : inComingChatBubbleConfig?.borderRadius ??
          (message.length < 29
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2));

  // Color get _color => isMessageBySender
  //     ? outgoingChatBubbleConfig?.color ?? Colors.purple
  //     : inComingChatBubbleConfig?.color ?? Colors.grey.shade500;
}



// class CustomChatBubble extends CustomPainter {
//   final Color color;
//   final bool isOwn;
//   CustomChatBubble({required this.color, required this.isOwn});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = color ?? Colors.blue;
//
//     Path paintBubbleTail() {
//       late Path path;
//       if (!isOwn) {
//         path = Path()
//           ..moveTo(5, size.height - 5)
//           ..quadraticBezierTo(-5, size.height, -16, size.height - 4)
//           ..quadraticBezierTo(-5, size.height - 5, 0, size.height - 17);
//       }
//       if (isOwn) {
//         path = Path()
//           ..moveTo(size.width - 6, size.height - 4)
//           ..quadraticBezierTo(
//               size.width + 5, size.height, size.width + 16, size.height - 4)
//           ..quadraticBezierTo(
//               size.width + 5, size.height - 5, size.width, size.height - 17);
//       }
//       return path;
//     }
//
//     final RRect bubbleBody = RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16));
//     final Path bubbleTail = paintBubbleTail();
//
//     canvas.drawRRect(bubbleBody, paint);
//     canvas.drawPath(bubbleTail, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     return true;
//   }
// }