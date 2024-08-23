import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:http/http.dart' as http;

class ChatPageUser extends StatefulWidget {
  const ChatPageUser({Key? key}) : super(key: key);

  @override
  State<ChatPageUser> createState() => _ChatPageUserState();
}

class _ChatPageUserState extends State<ChatPageUser> {
  //controller for chat text
  TextEditingController chatText = TextEditingController();

  //controller for scrolling chats
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;

  @override
  void initState() {
    getCurrentMessagesUser();
    super.initState();
  }
  void scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: valueNotifierHome.value,
              builder: (context, value, child) {
                scrollToBottom();
                messageSeenUser();
                return Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        media.width * 0.05,
                        MediaQuery.of(context).padding.top + media.width * 0.05,
                        media.width * 0.05,
                        media.width * 0.05,
                      ),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: media.width * 0.9,
                                height: media.width * 0.1,
                                alignment: Alignment.center,
                                child: Text(
                                  'Chat With User',
                                  style: GoogleFonts.roboto(
                                    fontSize: media.width * twenty,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Container(
                                    height: media.width * 0.1,
                                    width: media.width * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                        ),
                                      ],
                                      color: page,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.arrow_back),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              itemCount: chatListUser.length,
                              itemBuilder: (context, index) {
                                final chatItem = chatListUser[index];
                                bool isSentByUser = chatItem['from_type'] == 2;
                                return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: media.width * 0.025),
                                      width: media.width * 0.9,
                                      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: media.width * 0.5,
                                            padding: EdgeInsets.all(media.width * 0.04),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(24),
                                                bottomLeft: isSentByUser ? const Radius.circular(24) : const Radius.circular(0),
                                                bottomRight: isSentByUser ? const Radius.circular(0) : const Radius.circular(24),
                                                topRight: const Radius.circular(24),
                                              ),
                                              color: isSentByUser ? const Color(0xff000000).withOpacity(0.15) : const Color(0xff222222),
                                            ),
                                            child: Text(
                                              chatItem['message'],
                                              style: GoogleFonts.roboto(
                                                fontSize: media.width * fourteen,
                                                color: isSentByUser ? Colors.black : Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: media.width * 0.015),
                                          Text(chatItem['converted_created_at']),
                                        ],
                                      ),

                                    ),
                                    chatItem['seen']==1?
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children:const [
                                        Text("Seen"),
                                      ],
                                    ):const SizedBox.shrink(),
                                  ],
                                );

                              },
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: media.width * 0.025),
                            padding: EdgeInsets.fromLTRB(
                              media.width * 0.025,
                              media.width * 0.01,
                              media.width * 0.025,
                              media.width * 0.01,
                            ),
                            width: media.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderLines, width: 1.2),
                              color: page,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: media.width * 0.7,
                                  child: TextField(
                                    controller: chatText,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: languages[choosenLanguage]['text_entermessage'],
                                      hintStyle: GoogleFonts.roboto(
                                        fontSize: media.width * twelve,
                                        color: hintColor,
                                      ),
                                    ),
                                    minLines: 1,
                                    onChanged: (val) {},
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    setState(() {
                                      _sendingMessage = true;
                                    });

                                    await sendMessageUser(chatText.text);
                                    chatText.clear();
                                    setState(() {
                                      _sendingMessage = false;
                                    });
                                  },
                                  child: SizedBox(
                                    child: RotatedBox(
                                      quarterTurns: (languageDirection == 'rtl') ? 2 : 0,
                                      child: Image.asset(
                                        'assets/images/send.png',
                                        fit: BoxFit.contain,
                                        width: media.width * 0.075,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sendingMessage) const Positioned(top: 0, child: Loading()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
