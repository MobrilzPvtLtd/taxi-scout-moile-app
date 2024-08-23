import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatText = TextEditingController();
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;

  @override
  void initState() {
    getCurrentMessagesCompany();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              scrollToBottom();
              messageSeenCompany();
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
                                'Chat With Company',
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
                            itemCount: chatList.length,
                            itemBuilder: (context, index) {
                              final chatItem = chatList[index];
                              bool isSentByUser = chatItem["from_type"] == "is_driver";
                              String timestamp = chatItem["created_at"];
                              DateTime dateTime = DateTime.parse(timestamp);
                              String formattedTime = DateFormat('HH:mm').format(dateTime);
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
                                          child: Row(
                                            children: [
                                              Text(
                                                chatItem['message'] ?? "",
                                                style: GoogleFonts.roboto(
                                                  fontSize: media.width * fourteen,
                                                  color: isSentByUser ? Colors.black : Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              chatItem["from_type"] == "is_driver"?chatItem['seen_count']==1? Container(child: Image.asset('assets/images/double-check.png',height: 18,)): Container(child: Image.asset('assets/images/double-tick.png'),height: 18,):SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: media.width * 0.015),
                                        Text(formattedTime ?? ""),
                                      ],
                                    ),

                                  ),
                                  // chatItem['seen_count']==1?
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     Container(child: Image.asset('assets/images/double-check.png',height: 18,))
                                  //   ],
                                  // ):Row(
                                  //   children: [
                                  //     Container(child: Image.asset('assets/images/double-tick.png'),height: 18,),
                                  //   ],
                                //   ),
                                // ],
                              ]);

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

                                  await sendMessageCompany(chatText.text);
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
    );
  }
}
