import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents choice message widget
class ChoiceMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.ChoiceMessage] class
  const ChoiceMessage({
    Key? key,
    required this.message,
    required this.showName,
  }) : super(key: key);

  /// [types.ChoiceMessage]
  final types.ChoiceMessage message;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  Widget _textWidget(types.User user, BuildContext context) {
    final color = getUserAvatarNameColor(message.author,
        InheritedChatTheme.of(context).theme.userAvatarNameColors);
    final name = getUserName(message.author);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: InheritedChatTheme.of(context)
                  .theme
                  .userNameTextStyle
                  .copyWith(color: color),
            ),
          ),
        SelectableText(
          message.text,
          style: user.id == message.author.id
              ? InheritedChatTheme.of(context).theme.sentMessageBodyTextStyle
              : InheritedChatTheme.of(context)
                  .theme
                  .receivedMessageBodyTextStyle,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    //final _width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: _textWidget(_user, context),
    );
  }
}
