import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'dart:developer' as dev;

class TripChatPage extends StatefulWidget {
  final String id;
  const TripChatPage({Key? key, required this.id}) : super(key: key);

  @override
  State<TripChatPage> createState() => _TripChatPageState();
}

class _TripChatPageState extends State<TripChatPage> {
  //controller for chat text
  TextEditingController chatText = TextEditingController();

  ValueNotifier<List> chatList = ValueNotifier<List>([]);

  getMessages() async {
    try {
      var response = await http.get(
        Uri.parse('${url}api/v1/request/chat-history/${widget.id}'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success'] == true) {
          if (chatList.value
                  .where((element) => element['from_type'] == 1)
                  .length !=
              jsonDecode(response.body)['data']
                  .where((element) => element['from_type'] == 1)
                  .length) {
            audioPlayer.play(audio);
          }
          chatList.value = jsonDecode(response.body)['data'];
          // valueNotifierHome.incrementNotifier();
        }
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  }

  sendMessage(chat) async {
    dev.log("${{'request_id': widget.id, 'message': chat}}",
        name: "Send Message Request");
    try {
      var response = await http.post(Uri.parse('${url}api/v1/request/send'),
          headers: {
            'Authorization': 'Bearer ${bearerToken[0].token}',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'request_id': widget.id, 'message': chat}));
      if (response.statusCode == 200) {
        getMessages();
        FirebaseDatabase.instance
            .ref('requests/${widget.id}')
            .update({'message_by_driver': chatList.value.length});
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  }

  messageSeen() async {
    var response = await http.post(Uri.parse('${url}api/v1/request/seen'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': widget.id}));
    if (response.statusCode == 200) {
      getMessages();
    } else {
      debugPrint(response.body);
    }
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      dev.log("Message Searching!");
      // Code snippet to run every 2 seconds
      getMessages();
    });
  }

  //controller for scrolling chats
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;
  @override
  void initState() {
    dev.log(widget.id, name: "=======> Request ID");
    super.initState();
    startTimer();
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
        // rtl and ltr
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: ValueListenableBuilder<List>(
                valueListenable: chatList,
                builder: (context, chats, child) {
                  //api call for message seen
                  messageSeen();

                  return Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            media.width * 0.05,
                            MediaQuery.of(context).padding.top +
                                media.width * 0.05,
                            media.width * 0.05,
                            media.width * 0.05),
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
                                    languages[choosenLanguage]
                                        ['text_chatwithuser'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: textColor,
                                        fontWeight: FontWeight.w600),
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
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 2)
                                          ],
                                          color: page),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: controller,
                              child: (chats.isEmpty)
                                  ? Container(
                                      width: double.infinity,
                                      height: media.height * 0.7,
                                      alignment: Alignment.center,
                                      child: ImageIcon(
                                        const AssetImage(
                                            "assets/images/empty_chat.png"),
                                        size: 100.0,
                                        color: Colors.grey.shade300,
                                      ),
                                    )
                                  : Column(
                                      children: chats
                                          .asMap()
                                          .map((i, value) {
                                            return MapEntry(
                                                i,
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: media.width * 0.025),
                                                  width: media.width * 0.9,
                                                  alignment: (chats[i]
                                                              ['from_type'] ==
                                                          2)
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: Column(
                                                    crossAxisAlignment: (chats[
                                                                    i]
                                                                ['from_type'] ==
                                                            2)
                                                        ? CrossAxisAlignment.end
                                                        : CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width:
                                                            media.width * 0.5,
                                                        padding: EdgeInsets.all(
                                                            media.width * 0.04),
                                                        decoration: BoxDecoration(
                                                            borderRadius: (chats[i]['from_type'] == 2)
                                                                ? const BorderRadius.only(
                                                                    topLeft: Radius.circular(
                                                                        24),
                                                                    bottomLeft: Radius.circular(
                                                                        24),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            24))
                                                                : const BorderRadius.only(
                                                                    topRight: Radius.circular(
                                                                        24),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            24),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            24)),
                                                            color: (chats[i]['from_type'] == 2)
                                                                ? const Color(0xff000000).withOpacity(0.15)
                                                                : const Color(0xff222222)),
                                                        child: Text(
                                                          chats[i]['message'],
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      fourteen,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.015,
                                                      ),
                                                      Text(chats[i][
                                                          'converted_created_at'])
                                                    ],
                                                  ),
                                                ));
                                          })
                                          .values
                                          .toList(),
                                    ),
                            )),
                            Container(
                              margin: EdgeInsets.only(top: media.width * 0.025),
                              padding: EdgeInsets.fromLTRB(
                                  media.width * 0.025,
                                  media.width * 0.01,
                                  media.width * 0.025,
                                  media.width * 0.01),
                              width: media.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: borderLines, width: 1.2),
                                  color: page),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //checkpoint
                                  //chat box values
                                  SizedBox(
                                    width: media.width * 0.7,
                                    child: TextField(
                                      controller: chatText,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: languages[choosenLanguage]
                                              ['text_entermessage'],
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: hintColor)),
                                      minLines: 1,
                                      onChanged: (val) {},
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      //sendingMessage
                                      _sendingMessage = true;

                                      //api call for send message
                                      await sendMessage(chatText.text);
                                      chatText.clear();
                                      //_sendingMessage
                                      _sendingMessage = false;
                                    },
                                    child: SizedBox(
                                      child: RotatedBox(
                                          quarterTurns:
                                              (languageDirection == 'rtl')
                                                  ? 2
                                                  : 0,
                                          child: Image.asset(
                                            'assets/images/send.png',
                                            fit: BoxFit.contain,
                                            width: media.width * 0.075,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // loader
                      (_sendingMessage == true)
                          ? const Positioned(top: 0, child: Loading())
                          : Container()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
