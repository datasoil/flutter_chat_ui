import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/choice_button.dart';
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

  List<Widget> _buildChoicesList() {
    return message.choices
        .map((c) =>
            ChoiceButton(choice: c, onChoiceTap: onChoiceTap, message: message))
        .toList();
  }

  Widget _questionWidget(types.User user, BuildContext context) {
    final color = getUserAvatarNameColor(message.author,
        InheritedChatTheme.of(context).theme.userAvatarNameColors);
    final name = getUserName(message.author);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            parseMsgText(message.question),
            style: TextStyle(
                fontSize: 14,
                color:
                    user.id == message.author.id ? Colors.white : Colors.black,
                fontWeight: message.choices.isNotEmpty
                    ? FontWeight.bold
                    : FontWeight.normal),
          ),
          if (message.choices.isNotEmpty) const SizedBox(height: 5),
          Wrap(
            children: _buildChoicesList(),
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: _questionWidget(_user, context),
    );
  }
}
