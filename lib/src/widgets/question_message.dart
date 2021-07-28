import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents choice message widget
class QuestionMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.QuestionMessage] class
  const QuestionMessage({
    Key? key,
    required this.message,
    required this.showName,
    required this.onChoiceTap,
  }) : super(key: key);

  /// [types.QuestionMessage]
  final types.QuestionMessage message;

  /// Function when user select a choice
  final void Function(types.Choice, types.Message)? onChoiceTap;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  List<Widget> _buildChoicesList(types.User user) {
    return message.choices
        .map((e) => GestureDetector(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.text.toString(),
                      style: TextStyle(
                          color: user.id == message.author.id
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16),
                    ),
                    Divider(
                      color: user.id == message.author.id
                          ? Colors.white
                          : Colors.black,
                      indent: 10,
                      endIndent: 10,
                    )
                  ],
                )),
            onTap: () => {
                  onChoiceTap?.call(e, message),
                }))
        .toList();
  }

  Widget _questionWidget(types.User user, BuildContext context) {
    final color = getUserAvatarNameColor(message.author,
        InheritedChatTheme.of(context).theme.userAvatarNameColors);
    final name = getUserName(message.author);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
        Text(
          message.question,
          style: TextStyle(
              fontSize: 18,
              color: user.id == message.author.id ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
        message.choices.isEmpty
            ? Divider(
                color:
                    user.id == message.author.id ? Colors.white : Colors.black,
              )
            : SizedBox.shrink(),
        Column(
          children: _buildChoicesList(user),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _width = MediaQuery.of(context).size.width;

    return Container(
      width: _width * 4 / 5,
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: _questionWidget(_user, context),
    );
  }
}
