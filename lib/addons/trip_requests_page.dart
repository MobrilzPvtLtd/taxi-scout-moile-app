import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/addons/tripdetailpage.dart';
import 'dart:developer' as dev;

import '../styles/styles.dart';
import '../translation/translation.dart';

class TripRequests extends StatefulWidget {
  const TripRequests({Key? key}) : super(key: key);

  @override
  State<TripRequests> createState() => _TripRequestsState();
}

class _TripRequestsState extends State<TripRequests> {
  List upcomingTrips = [];
  List expiredTrips = [];

  int selectedHistory = 0;

  @override
  initState() {
    filterHistory();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  filterHistory() {
    for (var element in userDetails['laterTripRequest'].toList()) {
      dev.log(
          "${element['trip_start_time'].substring(0, 4)} -${element['trip_start_time'].substring(5, 7)} -${element['trip_start_time'].substring(8, 10)}");

      DateTime record = DateTime(
          int.parse(element['trip_start_time'].substring(0, 4)),
          int.parse(element['trip_start_time'].substring(5, 7)),
          int.parse(element['trip_start_time'].substring(8, 10)),
          int.parse(element['trip_start_time'].substring(11, 13)),
          int.parse(element['trip_start_time'].substring(14, 16)));

      if (record.difference(DateTime.now()) > const Duration(days: 1)) {
        upcomingTrips.add(element);
        // expiredTrips.add(element);
      } else {
        expiredTrips.add(element);
        // upcomingTrips.add(element);
      }

      // upcomingTrips.add(element);
    }
  }

  ValueNotifier<int> selectedTripType = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: const Text("Requests",
            style: TextStyle(
              color: Colors.black,
            )),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder(
          valueListenable: selectedTripType,
          builder: (context, value, snapshot) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: media.width * 0.13,
                    width: media.width * 1.0,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    decoration: BoxDecoration(
                        color: page,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 2,
                              spreadRadius: 2,
                              color: Colors.black.withOpacity(0.2))
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            selectedTripType.value = 0;
                          },
                          child: Container(
                              height: media.width * 0.13,
                              alignment: Alignment.center,
                              width: media.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: (selectedTripType.value == 0)
                                      ? const Color(0xff222222)
                                      : page),
                              child: Text(
                                languages[choosenLanguage]['text_upcoming'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * fifteen,
                                    fontWeight: FontWeight.w600,
                                    color: (selectedTripType.value == 0)
                                        ? Colors.white
                                        : textColor),
                              )),
                        ),
                        InkWell(
                          onTap: () async {
                            selectedTripType.value = 1;
                          },
                          child: Container(
                              height: media.width * 0.13,
                              alignment: Alignment.center,
                              width: media.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: (selectedTripType.value == 1)
                                      ? const Color(0xff222222)
                                      : page),
                              child: Text(
                                languages[choosenLanguage]['text_expired'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * fifteen,
                                    fontWeight: FontWeight.w600,
                                    color: (selectedTripType.value == 1)
                                        ? Colors.white
                                        : textColor),
                              )),
                        ),
                      ],
                    ),
                  ),
                  (value == 0)
                      ? upcomingTrips.isEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  height: media.width * 0.7,
                                  width: media.width * 0.7,
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/nodatafound.gif'),
                                          fit: BoxFit.contain)),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: upcomingTrips.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          upcomingTrips[i]['trip_start_time'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              fontWeight: FontWeight.w600,
                                              color: textColor),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            selectedHistory = i;
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TripDetail(
                                                          pins: {
                                                            "pickup": {
                                                              "pickup_address":
                                                                  upcomingTrips[
                                                                          i][
                                                                      'pick_address'],
                                                              "pickup_lat":
                                                                  upcomingTrips[
                                                                          i][
                                                                      'pick_lat'],
                                                              "pickup_long":
                                                                  upcomingTrips[
                                                                          i][
                                                                      'pick_lng'],
                                                            },
                                                            "drop": {
                                                              "drop_address":
                                                                  upcomingTrips[
                                                                              i]
                                                                          [
                                                                          'drop_address'] ??
                                                                      "",
                                                              "drop_lat":
                                                                  upcomingTrips[
                                                                          i][
                                                                      'drop_lat'],
                                                              "drop_long":
                                                                  upcomingTrips[
                                                                          i][
                                                                      'drop_lng'],
                                                            }
                                                          },
                                                          data:
                                                              upcomingTrips[i],
                                                          // isAccepted: true,
                                                          isAccepted: upcomingTrips[
                                                                          i][
                                                                      'transport_type'] !=
                                                                  null &&
                                                              upcomingTrips[i][
                                                                      'accepted_at'] !=
                                                                  null,
                                                        )));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: media.width * 0.025,
                                                bottom: media.width * 0.05,
                                                left: media.width * 0.015,
                                                right: media.width * 0.015),
                                            width: media.width * 0.85,
                                            padding: EdgeInsets.fromLTRB(
                                                media.width * 0.025,
                                                media.width * 0.05,
                                                media.width * 0.025,
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 2,
                                                      spreadRadius: 2,
                                                      color: Colors.black
                                                          .withOpacity(0.2))
                                                ]),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      upcomingTrips[i]
                                                          ['request_number'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  sixteen,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Image.asset(
                                                      (upcomingTrips[i][
                                                                  'transport_type'] ==
                                                              'taxi')
                                                          ? 'assets/images/taxiride.png'
                                                          : 'assets/images/deliveryride.png',
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.1,
                                                      fit: BoxFit.contain,
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          media.width * 0.16,
                                                      width: media.width * 0.16,
                                                      // "https://cdn4.iconfinder.com/data/icons/green-shopper/1068/user.png"
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage((upcomingTrips[
                                                                              i]
                                                                          [
                                                                          'profile_picture'] !=
                                                                      "/assets/images/default-profile-picture.jpeg")
                                                                  ? upcomingTrips[
                                                                          i][
                                                                      'profile_picture']
                                                                  : "https://cdn4.iconfinder.com/data/icons/green-shopper/1068/user.png"),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.02,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              media.width * 0.3,
                                                          child: Text(
                                                            upcomingTrips[i]
                                                                ['username'],
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    eighteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.01,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.06,
                                                              child: (upcomingTrips[
                                                                              i]
                                                                          [
                                                                          'payment_opt'] ==
                                                                      '1')
                                                                  ? Image.asset(
                                                                      'assets/images/cash.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    )
                                                                  : (upcomingTrips[i]
                                                                              [
                                                                              'payment_opt'] ==
                                                                          '2')
                                                                      ? Image
                                                                          .asset(
                                                                          'assets/images/wallet.png',
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        )
                                                                      : (upcomingTrips[i]['payment_opt'] ==
                                                                              '0')
                                                                          ? Image
                                                                              .asset(
                                                                              'assets/images/card.png',
                                                                              fit: BoxFit.contain,
                                                                            )
                                                                          : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.01,
                                                            ),
                                                            Text(
                                                              (upcomingTrips[i][
                                                                          'payment_opt'] ==
                                                                      '1')
                                                                  ? languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_cash']
                                                                  : (upcomingTrips[i]
                                                                              [
                                                                              'payment_opt'] ==
                                                                          '2')
                                                                      ? languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_wallet']
                                                                      : (upcomingTrips[i]['payment_opt'] ==
                                                                              '0')
                                                                          ? languages[choosenLanguage]
                                                                              [
                                                                              'text_card']
                                                                          : '',
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '₹' +
                                                                    ' ' +
                                                                    (upcomingTrips[i]['request_eta_amount'] ??
                                                                            0.00)
                                                                        .toString(),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.01,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    (upcomingTrips[i]['total_time'] <
                                                                            50)
                                                                        // ignore: prefer_interpolation_to_compose_strings
                                                                        ? upcomingTrips[i]['total_distance'].toString().toString() +
                                                                            "km" +
                                                                            ' - ' +
                                                                            upcomingTrips[i]['total_time']
                                                                                .toString() +
                                                                            ' mins'
                                                                        // ignore: prefer_interpolation_to_compose_strings
                                                                        : upcomingTrips[i]['total_distance'].toString() +
                                                                            "km" +
                                                                            ' - ' +
                                                                            (upcomingTrips[i]['total_time'] / 60).round().toString() +
                                                                            ' hr',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: const Color(
                                                                  0xffFF0000)
                                                              .withOpacity(
                                                                  0.3)),
                                                      child: Container(
                                                        height:
                                                            media.width * 0.025,
                                                        width:
                                                            media.width * 0.025,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(
                                                                    0xffFF0000)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.5,
                                                        child: Text(
                                                          upcomingTrips[i]
                                                              ['pick_address'],
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                        )),
                                                    Expanded(
                                                        child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          upcomingTrips[i][
                                                                  'trip_start_time']
                                                              .toString()
                                                              .substring(
                                                                  11, 16),
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      twelve,
                                                              color: const Color(
                                                                  0xff898989)),
                                                          textDirection:
                                                              TextDirection.ltr,
                                                        )
                                                      ],
                                                    ))
                                                  ],
                                                ),
                                                if (upcomingTrips[i]
                                                        ['drop_address'] !=
                                                    null)
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (upcomingTrips[i]
                                                            ['drop_address'] !=
                                                        null)
                                                      Container(
                                                        height:
                                                            media.width * 0.05,
                                                        width:
                                                            media.width * 0.05,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: const Color(
                                                                    0xff319900)
                                                                .withOpacity(
                                                                    0.3)),
                                                        child: Container(
                                                          height: media.width *
                                                              0.025,
                                                          width: media.width *
                                                              0.025,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Color(
                                                                      0xff319900)),
                                                        ),
                                                      ),
                                                    if (upcomingTrips[i]
                                                            ['drop_address'] !=
                                                        null)
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.05,
                                                      ),
                                                    if (upcomingTrips[i]
                                                            ['drop_address'] !=
                                                        null)
                                                      SizedBox(
                                                          width:
                                                              media.width * 0.5,
                                                          child: Text(
                                                            upcomingTrips[i][
                                                                    'drop_address'] ??
                                                                "",
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve),
                                                          )),
                                                    if (upcomingTrips[i][
                                                                'trip_end_time'] !=
                                                            null &&
                                                        upcomingTrips[i][
                                                                'drop_address'] !=
                                                            null)
                                                      Expanded(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            upcomingTrips[i][
                                                                    'trip_end_time']
                                                                .toString()
                                                                .substring(
                                                                    11, 16),
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve,
                                                                color: const Color(
                                                                    0xff898989)),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          )
                                                        ],
                                                      ))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            )
                      : (expiredTrips.isEmpty)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  height: media.width * 0.7,
                                  width: media.width * 0.7,
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/nodatafound.gif'),
                                          fit: BoxFit.contain)),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: expiredTrips.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expiredTrips[i]['trip_start_time'],
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              fontWeight: FontWeight.w600,
                                              color: textColor),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            selectedHistory = i;
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TripDetail(
                                                          pins: {
                                                            "pickup": {
                                                              "pickup_address":
                                                                  expiredTrips[
                                                                          i][
                                                                      'pick_address'],
                                                              "pickup_lat":
                                                                  expiredTrips[
                                                                          i][
                                                                      'pick_lat'],
                                                              "pickup_long":
                                                                  expiredTrips[
                                                                          i][
                                                                      'pick_lng'],
                                                            },
                                                            "drop": {
                                                              "drop_address":
                                                                  expiredTrips[
                                                                              i]
                                                                          [
                                                                          'drop_address'] ??
                                                                      "",
                                                              "drop_lat":
                                                                  expiredTrips[
                                                                          i][
                                                                      'drop_lat'],
                                                              "drop_long":
                                                                  expiredTrips[
                                                                          i][
                                                                      'drop_lng'],
                                                            }
                                                          },
                                                          data: expiredTrips[i],
                                                          isAccepted: null,
                                                        )));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: media.width * 0.025,
                                                bottom: media.width * 0.05,
                                                left: media.width * 0.015,
                                                right: media.width * 0.015),
                                            width: media.width * 0.85,
                                            padding: EdgeInsets.fromLTRB(
                                                media.width * 0.025,
                                                media.width * 0.05,
                                                media.width * 0.025,
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 2,
                                                      spreadRadius: 2,
                                                      color: Colors.black
                                                          .withOpacity(0.2))
                                                ]),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      expiredTrips[i]
                                                          ['request_number'],
                                                      style: GoogleFonts.roboto(
                                                          fontSize:
                                                              media.width *
                                                                  sixteen,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Image.asset(
                                                      (expiredTrips[i][
                                                                  'transport_type'] ==
                                                              'taxi')
                                                          ? 'assets/images/taxiride.png'
                                                          : 'assets/images/deliveryride.png',
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.1,
                                                      fit: BoxFit.contain,
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          media.width * 0.16,
                                                      width: media.width * 0.16,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage((expiredTrips[
                                                                              i]
                                                                          [
                                                                          'profile_picture'] !=
                                                                      "/assets/images/default-profile-picture.jpeg")
                                                                  ? expiredTrips[
                                                                          i][
                                                                      'profile_picture']
                                                                  : "https://cdn4.iconfinder.com/data/icons/green-shopper/1068/user.png"),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.02,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              media.width * 0.3,
                                                          child: Text(
                                                            expiredTrips[i]
                                                                ['username'],
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    eighteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.01,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.06,
                                                              child: (expiredTrips[
                                                                              i]
                                                                          [
                                                                          'payment_opt'] ==
                                                                      '1')
                                                                  ? Image.asset(
                                                                      'assets/images/cash.png',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    )
                                                                  : (expiredTrips[i]
                                                                              [
                                                                              'payment_opt'] ==
                                                                          '2')
                                                                      ? Image
                                                                          .asset(
                                                                          'assets/images/wallet.png',
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        )
                                                                      : (expiredTrips[i]['payment_opt'] ==
                                                                              '0')
                                                                          ? Image
                                                                              .asset(
                                                                              'assets/images/card.png',
                                                                              fit: BoxFit.contain,
                                                                            )
                                                                          : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.01,
                                                            ),
                                                            Text(
                                                              (expiredTrips[i]
                                                                          [
                                                                          'payment_opt'] ==
                                                                      '1')
                                                                  ? languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_cash']
                                                                  : (expiredTrips[i]
                                                                              [
                                                                              'payment_opt'] ==
                                                                          '2')
                                                                      ? languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_wallet']
                                                                      : (expiredTrips[i]['payment_opt'] ==
                                                                              '0')
                                                                          ? languages[choosenLanguage]
                                                                              [
                                                                              'text_card']
                                                                          : '',
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                '₹' +
                                                                    ' ' +
                                                                    (expiredTrips[i]['total_amount'] ??
                                                                            "0.00")
                                                                        .toString(),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.01,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    (expiredTrips[i]['total_time'] <
                                                                            50)
                                                                        // ignore: prefer_interpolation_to_compose_strings
                                                                        ? expiredTrips[i]['total_distance'].toString() +
                                                                            "Km" +
                                                                            ' - ' +
                                                                            expiredTrips[i]['total_time']
                                                                                .toString() +
                                                                            ' mins'
                                                                        : expiredTrips[i]['total_distance'] +
                                                                            expiredTrips[i]['unit'] +
                                                                            ' - ' +
                                                                            (expiredTrips[i]['total_time'] / 60).round().toString() +
                                                                            ' hr',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: const Color(
                                                                  0xffFF0000)
                                                              .withOpacity(
                                                                  0.3)),
                                                      child: Container(
                                                        height:
                                                            media.width * 0.025,
                                                        width:
                                                            media.width * 0.025,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(
                                                                    0xffFF0000)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.5,
                                                        child: Text(
                                                          expiredTrips[i]
                                                              ['pick_address'],
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                        )),
                                                    if (expiredTrips[i][
                                                            'trip_start_time'] !=
                                                        null)
                                                      Expanded(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            expiredTrips[i][
                                                                    'trip_start_time']
                                                                .toString()
                                                                .substring(
                                                                    11, 16),
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve,
                                                                color: const Color(
                                                                    0xff898989)),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          )
                                                        ],
                                                      ))
                                                  ],
                                                ),
                                                if (expiredTrips[i]
                                                        ['drop_address'] !=
                                                    null)
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                if (expiredTrips[i]
                                                        ['drop_address'] !=
                                                    null)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height:
                                                            media.width * 0.05,
                                                        width:
                                                            media.width * 0.05,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: const Color(
                                                                    0xff319900)
                                                                .withOpacity(
                                                                    0.3)),
                                                        child: Container(
                                                          height: media.width *
                                                              0.025,
                                                          width: media.width *
                                                              0.025,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Color(
                                                                      0xff319900)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.05,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              media.width * 0.5,
                                                          child: Text(
                                                            expiredTrips[i][
                                                                    'drop_address'] ??
                                                                "",
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve),
                                                          )),
                                                      if (expiredTrips[i][
                                                              'trip_end_time'] !=
                                                          null)
                                                        Expanded(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              expiredTrips[i][
                                                                      'trip_end_time']
                                                                  .toString()
                                                                  .substring(
                                                                      11, 16),
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  color: const Color(
                                                                      0xff898989)),
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                            )
                                                          ],
                                                        ))
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                ],
              ),
            );
          }),
    );
  }
}
