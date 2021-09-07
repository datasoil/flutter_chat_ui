import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../chat_l10n.dart';
import '../chat_theme.dart';
import '../conditional/conditional.dart';
import '../models/date_header.dart';
import '../models/message_spacer.dart';
import '../models/preview_image.dart';
import '../util.dart';
import 'chat_list.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'input.dart';
import 'message.dart';

/// Entry widget, represents the complete chat
class ChatClient extends StatefulWidget {
  /// Creates a chat widget
  const ChatClient({
    Key? key,
    this.buildCustomMessage,
    this.customDateHeaderText,
    this.dateFormat,
    this.dateLocale,
    this.disableImageGallery,
    this.emptyState,
    this.isAttachmentUploading,
    this.isLastPage,
    this.l10n = const ChatL10nEn(),
    required this.messages,
    this.onAttachmentPressed,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageLongPress,
    this.onMessageTap,
    this.onVideoTap,
    this.onPreviewDataFetched,
    this.onChoiceSelect,
    required this.onSendPressed,
    this.onTextChanged,
    this.showUserAvatars = false,
    this.showUserNames = false,
    this.theme = const DefaultChatTheme(),
    this.timeFormat,
    this.usePreviewData = true,
    required this.user,
    this.textInputVisibility = false,
    this.mediaInputVisibility = false,
    this.restartConv = false,
    required this.onResetButtonTap
  }) : super(key: key);

  /// for activating and deactivating text input
  final bool textInputVisibility;

  /// for activating and deactivating media input
  final bool mediaInputVisibility;
  /// for activating a new conversation whe the previus is completed
  final bool restartConv;
  ///
  final void Function(String) onResetButtonTap;
  /// See [Message.buildCustomMessage]
  final Widget Function(types.Message)? buildCustomMessage;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to
  /// customize date headers in your case, use this to return an arbitrary
  /// string based on a [DateTime] of a particular message. Can be helpful to
  /// return "Today" if [DateTime] is today. IMPORTANT: this will replace
  /// all default date headers, so you must handle all cases yourself, like
  /// for example today, yesterday and before. Or you can just return the same
  /// date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// Allows you to customize the date format. IMPORTANT: only for the date,
  /// do not return time here. See [timeFormat] to customize the time format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized date
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? dateFormat;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat], [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [Input.isAttachmentUploading]
  final bool? isAttachmentUploading;

  /// See [ChatList.isLastPage]
  final bool? isLastPage;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain variables, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// List of [types.Message] to render in the chat widget
  final List<types.Message> messages;

  /// See [Input.onAttachmentPressed]
  final void Function()? onAttachmentPressed;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  final void Function(types.VideoMessage)? onVideoTap;

  final void Function(types.Choice, types.Message)? onChoiceSelect;

  /// See [Message.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText) onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// See [Message.showUserAvatars]
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// variables, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time,
  /// do not return date here. See [dateFormat] to customize the date format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized time
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? timeFormat;

  /// See [Message.usePreviewData]
  final bool usePreviewData;

  /// See [InheritedUser.user]
  final types.User user;

  @override
  _ChatClientState createState() => _ChatClientState();
}

/// [Chat] widget state
class _ChatClientState extends State<ChatClient> {
  List<Object> _chatMessages = [];
  List<PreviewImage> _gallery = [];
  int _imageViewIndex = 0;
  bool _isImageViewVisible = false;
  bool _isMediaInputVisible = false;
  bool _isKeyboardInputVisible = false;
  bool _isRestartConvButtonVisible = false;
  @override
  void initState() {
    super.initState();
    // settiamo le due variabili con i valori passati nel costruttore della chat
    debugPrint("also triggerata init state");
    _isMediaInputVisible = widget.mediaInputVisibility ;
    _isKeyboardInputVisible = widget.textInputVisibility;
    _isRestartConvButtonVisible = widget.restartConv;
    //
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ChatClient oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final result = calculateChatMessages(
        widget.messages,
        widget.user,
        customDateHeaderText: widget.customDateHeaderText,
        dateFormat: widget.dateFormat,
        dateLocale: widget.dateLocale,
        showUserNames: widget.showUserNames,
        timeFormat: widget.timeFormat,
      );

      _chatMessages = result[0] as List<Object>;
      _gallery = result[1] as List<PreviewImage>;
    }
  }

  Widget _buildEmptyState() {
    return widget.emptyState ??
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Text(
            widget.l10n.emptyChatPlaceholder,
            style: widget.theme.emptyChatPlaceholderTextStyle,
            textAlign: TextAlign.center,
          ),
        );
  }

  Widget _buildImageGallery() {
    debugPrint('image gallery built');
    return Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) =>
                PhotoViewGalleryPageOptions(
              imageProvider: Conditional().getProvider(_gallery[index].uri),
            ),
            itemCount: _gallery.length,
            loadingBuilder: (context, event) =>
                _imageGalleryLoadingBuilder(context, event),
            onPageChanged: _onPageChanged,
            pageController: PageController(initialPage: _imageViewIndex),
            scrollPhysics: const ClampingScrollPhysics(),
          ),
          Positioned(
            right: 16,
            top: 56,
            child: CloseButton(
              color: Colors.white,
              onPressed: _onCloseGalleryPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Object object) {
    if (object is DateHeader) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          bottom: 32,
          top: 16,
        ),
        child: Text(
          object.text,
          style: widget.theme.dateDividerTextStyle,
        ),
      );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else {
      final map = object as Map<String, Object>;
      final message = map['message']! as types.Message;
      final _messageWidth =
          widget.showUserAvatars && message.author.id != widget.user.id
              ? min(MediaQuery.of(context).size.width * 0.72, 440).floor()
              : min(MediaQuery.of(context).size.width * 0.78, 440).floor();

      return Message(
        key: ValueKey(message.id),
        buildCustomMessage: widget.buildCustomMessage,
        message: message,
        messageWidth: _messageWidth,
        onChoiceSelect: widget.onChoiceSelect,
        onVideoTap: widget.onVideoTap,
        onMessageLongPress: widget.onMessageLongPress,
        onMessageTap: (tappedMessage) {
          if (tappedMessage is types.ImageMessage &&
              widget.disableImageGallery != true) {
            _onImagePressed(tappedMessage);
          }

          widget.onMessageTap?.call(tappedMessage);
        },
        onPreviewDataFetched: _onPreviewDataFetched,
        roundBorder: map['nextMessageInGroup'] == true,
        showAvatar:
            widget.showUserAvatars && map['nextMessageInGroup'] == false,
        showName: map['showName'] == true,
        showStatus: map['showStatus'] == true,
        showUserAvatars: widget.showUserAvatars,
        usePreviewData: widget.usePreviewData,
      );
    }
  }

  Widget _imageGalleryLoadingBuilder(
    BuildContext context,
    ImageChunkEvent? event,
  ) {
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: event == null || event.expectedTotalBytes == null
              ? 0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
        ),
      ),
    );
  }

  void _onCloseGalleryPressed() {
    setState(() {
      debugPrint('premuto tasto chiusura gallery');
      _isImageViewVisible = false;
      this._isMediaInputVisible = false;
      _isKeyboardInputVisible = false;
    });
  }

  void _onImagePressed(types.ImageMessage message) {
    setState(() {
      _imageViewIndex = _gallery.indexWhere(
        (element) => element.id == message.id && element.uri == message.uri,
      );
      _isImageViewVisible = true;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _imageViewIndex = index;
    });
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  Widget createNoInputBanner(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height / 10;
    return Container(
      color: Colors.green,
      // ignore: sort_child_properties_last
      child: const Center(
          child: Text('Input is temporary disabled',
              style: TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  height: 1.333))),
      width: width,
      height: height,
    );
  }

  Widget createMediaInputOnly(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width / 2;
    var height = size.height / 6;
    return Container(
        color: Colors.orange,
        height: height,
        width: width,
        child: const InkResponse(
            //  onTap: widget.onAttachmentPressed,
            child: Text(
                'Qui ci va img') // Ink.image(image: const AssetImage('assets/attach.png')),
            ));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build triggerata con ' + (_isMediaInputVisible ? "true":"false")+ (_isKeyboardInputVisible ? "true":"false"));
    return InheritedUser(
      user: widget.user,
      child: InheritedChatTheme(
        theme: widget.theme,
        child: InheritedL10n(
          l10n: widget.l10n,
          child: Stack(
            children: [
              Container(
                color: widget.theme.backgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Flexible(
                        child: widget.messages.isEmpty
                            ? SizedBox.expand(
                                child: _buildEmptyState(),
                              )
                            : GestureDetector(
                                onTap: () => FocusManager.instance.primaryFocus
                                    ?.unfocus(),
                                child: ChatList(
                                  isLastPage: widget.isLastPage,
                                  itemBuilder: (item, index) =>
                                      _buildMessage(item),
                                  items: _chatMessages,
                                  onEndReached: widget.onEndReached,
                                  onEndReachedThreshold:
                                      widget.onEndReachedThreshold,
                                ),
                              ),
                      ),
                      // ignore: prefer_if_elements_to_conditional_expressions
                      widget.textInputVisibility
                          ? Input(
                              isAttachmentUploading:
                                  widget.isAttachmentUploading,
                              onAttachmentPressed: widget.onAttachmentPressed,
                              onSendPressed: widget.onSendPressed,
                              onTextChanged: widget.onTextChanged,
                            )
                          : (widget.mediaInputVisibility
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: widget.theme.primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.height / 10,
                                  margin: EdgeInsets.only(bottom: 25, top: 25),
                                  child: ElevatedButton(
                                      onPressed: widget.onAttachmentPressed,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 5, top: 5),
                                        child: Image.asset(
                                          'assets/icon-attach.png',
                                          package: 'flutter_chat_ui',
                                        ),
                                        //   tooltip:
                                        //      InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
                                      )), //Ink.image(image: AssetImage('assets/icon-attach.png')),
                                )
                              : (createNoInputBanner(context)))
                    ],
                  ),
                ),
              ),
              if (_isImageViewVisible) _buildImageGallery(),
            ],
          ),
        ),
      ),
    );
  }
}
