import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents choice message widget
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    Key? key,
    required this.choice,
    required this.onChoiceTap,
    required this.message,
  }) : super(key: key);

  /// Function when user select a choice
  final void Function(types.Choice, types.Message)? onChoiceTap;

  final types.Choice choice;

  /// [types.QuestionMessage]
  final types.QuestionMessage message;

  @override
  Widget build(BuildContext context) {
    final userId = InheritedUser.of(context).user.id;
    final authorId = message.author.id;
    return GestureDetector(
      onTap: () => {
        onChoiceTap?.call(choice, message),
      },
      child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 80.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
                color: const Color(0xffC2CAF9).withOpacity(.3),
                //border: Border.all(),
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              parseMsgText(choice.text),
              textAlign: TextAlign.center,
              style: userId == authorId
                  ? InheritedChatTheme.of(context)
                      .theme
                      .sentMessageBodyTextStyle
                  : InheritedChatTheme.of(context)
                      .theme
                      .receivedMessageBodyTextStyle,
            ),
          )),
    );
  }
}
