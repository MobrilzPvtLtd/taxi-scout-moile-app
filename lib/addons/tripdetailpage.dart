import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'trip_chat_page.dart';
import 'dart:developer' as dev;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate(this.latitude, this.longitude);
}

class TripDetail extends StatefulWidget {
  /*
    Map Format: {
      "pickup" : {
        "pickup_address": "",
        "pickup_lat": "",
        "pickup_long": "",
      },
      "drop": {
        "drop_address": "",
        "drop_lat": "",
        "drop_long": "",
      }
    }
  */
  final Map pins;
  final Map data;
  final bool? isAccepted;
  const TripDetail(
      {Key? key,
      required this.pins,
      required this.data,
      required this.isAccepted})
      : super(key: key);

  @override
  State<TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<TripDetail> {
  final Map<String, Marker> _markers = {};
  late GoogleMapController _controller;

  Uint8List? pickMarker;
  Uint8List? dropMarker;
  Uint8List? vehicleMarker;

  ValueNotifier<bool> showChat = ValueNotifier<bool>(false);

  ValueNotifier<LocationData?> getCurrentLocation =
      ValueNotifier<LocationData?>(null);

  Set<Polyline> historyPolyLine = {};

  List<LatLng> historyPolyList = [];
  String historyDropDistance = '';

  ValueNotifier<bool?> accepter = ValueNotifier<bool?>(null);

  getHistoryPolyLines(double argpickLat, double argpickLng, double argdropLat,
      double argdropLng) async {
    // String pickLat;
    // String pickLng;
    // String dropLat;
    // String dropLng;

    historyPolyList.clear();
    historyPolyLine.clear();

    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${argpickLat.toString()}%2C${argpickLng.toString()}&destination=${argdropLat.toString()}%2C${argdropLng.toString()}&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
      if (response.statusCode == 200) {
        var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']
            ['points'];
        historyDropDistance = jsonDecode(response.body)['routes'][0]['legs'][0]
            ['distance']['text'];
        historyPolyLine.clear();
        decodeEncodedHistoryPolyline(steps,
            [LatLng(argpickLat, argpickLng), LatLng(argdropLat, argdropLng)]);
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
    // if (tripStops.isEmpty) {
    //   try {
    //     var response = await http.get(Uri.parse(
    //         'https://maps.googleapis.com/maps/api/directions/json?origin=${argpickLat.toString()}%2C${argpickLng.toString()}&destination=${argdropLat.toString()}%2C${argdropLng.toString()}&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
    //     if (response.statusCode == 200) {
    //       var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']
    //           ['points'];
    //       historyDropDistance = jsonDecode(response.body)['routes'][0]['legs'][0]
    //           ['distance']['text'];

    //       decodeEncodedPolyline(steps);
    //     } else {
    //       debugPrint(response.body);
    //     }
    //   } catch (e) {
    //     if (e is SocketException) {
    //       internet = false;
    //     }
    //   }
    // } else {
    //   for (var i = 0; i < tripStops.length; i++) {
    //     if (i == 0) {
    //       pickLat = argpickLat.toString();
    //       pickLng = argpickLng.toString();
    //       dropLat = tripStops[i]['latitude'].toString();
    //       dropLng = tripStops[i]['longitude'].toString();
    //     } else {
    //       pickLat = tripStops[i - 1]['latitude'].toString();
    //       pickLng = tripStops[i - 1]['longitude'].toString();
    //       dropLat = tripStops[i]['latitude'].toString();
    //       dropLng = tripStops[i]['longitude'].toString();
    //     }
    //     try {
    //       var response = await http.get(Uri.parse(
    //           'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));
    //       if (response.statusCode == 200) {
    //         var steps = jsonDecode(response.body)['routes'][0]
    //             ['overview_polyline']['points'];

    //         decodeEncodedHistoryPolyline(steps);
    //       } else {
    //         debugPrint(response.body);
    //       }
    //     } catch (e) {
    //       if (e is SocketException) {
    //         internet = false;
    //       }
    //     }
    //   }
    // }
    return historyPolyList;
  }

  Future<int?> getMessagesCount() async {
    int messageCount = 0;
    dev.log("Running this function!");
    try {
      var response = await http.get(
        Uri.parse('${url}api/v1/request/chat-history/${widget.data['req_id']}'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        messageCount = 0;
        if (jsonDecode(response.body)['success'] == true) {
          List value = jsonDecode(response.body)['data'];

          dev.log("$value", name: "Messages");

          for (var element in value) {
            if (element['from_type'] == 1 && element['seen'] == 0) {
              messageCount += 1;
            }
          }

          // valueNotifierHome.incrementNotifier();
          dev.log("Int: $messageCount");
          return messageCount;
        } else {
          return 0;
        }
      } else {
        debugPrint(response.body);
        return 0;
      }
    } catch (e) {
      dev.log("Found an exception");
      if (e is SocketException) {
        internet = false;
        return 0;
      }
    }
    return messageCount;
  }

  decodeEncodedHistoryPolyline(String encoded, List<LatLng> twoPoints) {
    historyPolyLine.clear();
    historyPolyList.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      polyList.add(p);
    }

    if (polyList != twoPoints) {
      historyPolyLine.add(Polyline(
        polylineId: const PolylineId('1'),
        visible: true,
        color: const Color(0xffFD9898),
        width: 4,
        points: polyList,
      ));
    }
    valueNotifierHome.incrementNotifier();
  }

  requestAccept() async {
    try {
      var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
          headers: {
            'Authorization': 'Bearer ${bearerToken[0].token}',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(
              {'request_id': widget.data['req_id'], 'is_accept': 1}));

      if (response.statusCode == 200) {
        // AwesomeNotifications().cancel(7425);
        dev.log("Accepted Response: ${response.body}");
        if (jsonDecode(response.body)['message'] == 'success') {
          accepter.value = true;
          if (audioPlayers.state != PlayerState.STOPPED) {
            audioPlayers.stop();
            audioPlayers.dispose();
          }
          dropDistance = '';

          await getUserDetails();

          if (driverReq.isNotEmpty) {
            FirebaseDatabase.instance
                .ref()
                .child('drivers/${userDetails['id']}')
                .update({'is_available': false});
          }
          valueNotifierHome.incrementNotifier();
        }
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        valueNotifierHome.incrementNotifier();
      }
    }
  }

  requestReject() async {
    try {
      var response = await http.post(Uri.parse('${url}api/v1/request/respond'),
          headers: {
            'Authorization': 'Bearer ${bearerToken[0].token}',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(
              {'request_id': widget.data['req_id'], 'is_accept': 0}));

      if (response.statusCode == 200) {
        dev.log("Rejection Response: ${response.body}");
        // AwesomeNotifications().cancel(7425);
        if (jsonDecode(response.body)['message'] == 'success') {
          accepter.value = false;
          if (audioPlayers.state != PlayerState.STOPPED) {
            audioPlayers.stop();
            audioPlayers.dispose();
          }

          await getUserDetails();
        }
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        valueNotifierHome.incrementNotifier();
      }
    }
  }

  Timer? timer;
  ValueNotifier<int> newMessagesCount = ValueNotifier(0);

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      dev.log("Messags searching!");
      checkIfNewMessageReceived();
      // Code snippet to run every 2 seconds
    });
  }

  checkIfNewMessageReceived() {
    dev.log("checking value");
    newMessagesCount.value = (chatList.where(
            (element) => element['from_type'] == 1 && element['seen'] == 0))
        .toList()
        .length;
    dev.log("Unseen count: ${newMessagesCount.value}");
  }

  @override
  initState() {
    accepter.value = widget.isAccepted;
    historyPolyLine.clear();
    creatingMarkers();
    super.initState();
    startTimer();
  }

  LatLng calculateCenterPoint(double latitude1, double longitude1,
      double? latitude2, double? longitude2) {
    if (latitude2 != null && longitude2 != null) {
      double avgLat = (latitude1 + latitude2) / 2;
      double avgLon = (longitude1 + longitude2) / 2;

      return LatLng(avgLat, avgLon);
    } else {
      double lat1 = latitude1;
      double lon1 = longitude1;
      return LatLng(lat1, lon1);
    }
  }

  centeringCamera() {
    var center = calculateCenterPoint(
        widget.pins['pickup']["pickup_lat"],
        widget.pins['pickup']["pickup_long"],
        widget.pins['drop']["drop_lat"],
        widget.pins['drop']["drop_long"]);
    _controller.animateCamera(CameraUpdate.newLatLngZoom(center, 10.0));
  }

  void _onMapCreated(GoogleMapController controller) async {
    await creatingMarkers();
    _controller = controller;

    if (widget.pins['pickup']['pickup_address'].isNotEmpty &&
        pickMarker != null) {
      final marker1 = Marker(
          markerId: const MarkerId("Pickup"),
          position: LatLng(widget.pins['pickup']["pickup_lat"],
              widget.pins['pickup']["pickup_long"]),
          infoWindow: InfoWindow(
            title: "Pickup Address",
            snippet: widget.pins['pickup']['pickup_address'],
          ),
          icon: BitmapDescriptor.fromBytes(pickMarker!));
      _markers["pickup"] = marker1;
    }

    if (widget.pins['drop']['drop_address'].isNotEmpty) {
      final marker2 = Marker(
          markerId: const MarkerId("Drop"),
          position: LatLng(widget.pins['drop']["drop_lat"],
              widget.pins['drop']["drop_long"]),
          infoWindow: InfoWindow(
            title: "DropAddress",
            snippet: widget.pins['drop']['drop_address'],
          ),
          icon: BitmapDescriptor.fromBytes(dropMarker!));
      _markers["drop"] = marker2;
    }

    if (widget.data['transport_type'].isNotEmpty && center != null) {
      dev.log("Marker 3 being created");
      final marker3 = Marker(
          markerId: const MarkerId("Car"),
          position: center,
          infoWindow: InfoWindow(
            title: "DropAddress",
            snippet: widget.pins['drop']['drop_address'],
          ),
          icon: BitmapDescriptor.fromBytes(vehicleMarker!));
      _markers["car"] = marker3;
    }

    // setState(() {
    //   _markers.clear();

    // });
    centeringCamera();
    // String pickLat, String pickLng, String dropLat, String dropLng

    historyPolyLine.clear();
    historyPolyList.clear();
    if (widget.pins['drop']['drop_address'].isNotEmpty) {
      await getHistoryPolyLines(
          widget.pins['pickup']['pickup_lat'],
          widget.pins['pickup']['pickup_long'],
          widget.pins['drop']['drop_lat'],
          widget.pins['drop']['drop_long']);
      getLatLngBounds();
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {});
      });
    }
  }

  calculateUserPosition() async {
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();

    return locationData;
  }

  getLatLngBounds() {
    LatLngBounds bound;
    if (widget.pins['pickup']['pickup_lat'] > widget.pins['drop']['drop_lat'] &&
        widget.pins['pickup']['pickup_long'] >
            widget.pins['drop']['drop_long']) {
      bound = LatLngBounds(
          southwest: LatLng(widget.pins['drop']['drop_lat'],
              widget.pins['drop']['drop_long']),
          northeast: LatLng(widget.pins['pickup']['pickup_lat'],
              widget.pins['pickup']['pickup_long']));
    } else if (widget.pins['pickup']['pickup_long'] >
        widget.pins['drop']['drop_long']) {
      bound = LatLngBounds(
          southwest: LatLng(widget.pins['pickup']['pickup_lat'],
              widget.pins['drop']['drop_long']),
          northeast: LatLng(widget.pins['drop']['drop_lat'],
              widget.pins['pickup']['pickup_long']));
    } else if (widget.pins['pickup']['pickup_lat'] >
        widget.pins['drop']['drop_lat']) {
      bound = LatLngBounds(
          southwest: LatLng(widget.pins['drop']['drop_lat'],
              widget.pins['pickup']['pickup_long']),
          northeast: LatLng(widget.pins['pickup']['pickup_lat'],
              widget.pins['drop']['drop_long']));
    } else {
      bound = LatLngBounds(
          southwest: LatLng(widget.pins['pickup']['pickup_lat'],
              widget.pins['pickup']['pickup_long']),
          northeast: LatLng(widget.pins['drop']['drop_lat'],
              widget.pins['drop']['drop_long']));
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
    _controller.animateCamera(cameraUpdate);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  creatingMarkers() async {
    pickMarker = await getBytesFromAsset('assets/images/userloc.png', 40);
    dropMarker = await getBytesFromAsset('assets/images/droploc.png', 40);
    if (widget.data['transport_type'] == "taxi") {
      vehicleMarker = await getBytesFromAsset('assets/images/top-taxi.png', 40);
    } else if (widget.data['transport_type'] == "truck") {
      vehicleMarker =
          await getBytesFromAsset('assets/images/offlineicon_delivery.png', 40);
    } else if (widget.data['transport_type'] == "motor bike") {
      vehicleMarker = await getBytesFromAsset('assets/images/bike.png', 40);
    } else {
      vehicleMarker = await getBytesFromAsset('assets/images/top-taxi.png', 40);
    }
  }

  // void _animateToCenter() async {
  //   final GoogleMapController controller = _controller;
  //   controller.animateCamera(
  //     CameraUpdate.newLatLngZoom(targetCoordinates, 15),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var mediaView = MediaQuery.of(context).size;
    dev.log("${widget.data['profile_picture']}");
    dev.log("${widget.data['req_id']}");
    dev.log("${widget.pins}");
    return Directionality(
      textDirection:
          (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black),
          ),
          title: const Text("Requests",
              style: TextStyle(
                color: Colors.black,
              )),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: mediaView.height * 0.4,
                child: GoogleMap(
                  padding: EdgeInsets.only(
                      bottom: 0.0,
                      top: mediaView.height * 0.1 +
                          MediaQuery.of(context).padding.top),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 10,
                  ),
                  markers: _markers.values.toSet(),
                  polylines: historyPolyLine,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: mediaView.width * 0.05,
                    bottom: mediaView.width * 0.05,
                    left: mediaView.width * 0.05,
                    right: mediaView.width * 0.05),
                width: mediaView.width * 0.90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: page,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.data['request_number'],
                          style: GoogleFonts.roboto(
                              fontSize: mediaView.width * sixteen,
                              fontWeight: FontWeight.w600),
                        ),
                        Image.asset(
                          (widget.data['transport_type'] == 'taxi')
                              ? 'assets/images/taxiride.png'
                              : 'assets/images/deliveryride.png',
                          height: mediaView.width * 0.05,
                          width: mediaView.width * 0.1,
                          fit: BoxFit.contain,
                        )
                      ],
                    ),
                    SizedBox(
                      height: mediaView.width * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            dev.log(
                                '${{
                                  'request_id': widget.data['req_id'],
                                  'is_accept': 1
                                }}',
                                name: "Request Body");
                            dev.log("All the Data I'm getting: ${widget.data}");
                          },
                          child: Container(
                            height: mediaView.width * 0.16,
                            width: mediaView.width * 0.16,
                            decoration: (widget.data['profile_picture'] !=
                                    "/assets/images/default-profile-picture.jpeg")
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            widget.data['profile_picture']),
                                        fit: BoxFit.cover))
                                : const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            "https://cdn4.iconfinder.com/data/icons/green-shopper/1068/user.png"))),
                          ),
                        ),
                        SizedBox(
                          width: mediaView.width * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: mediaView.width * 0.3,
                              child: Text(
                                widget.data['username'],
                                style: GoogleFonts.roboto(
                                    fontSize: mediaView.width * eighteen,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: mediaView.width * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: mediaView.width * 0.06,
                                  child: (widget.data['payment_opt'] == '1')
                                      ? Image.asset(
                                          'assets/images/cash.png',
                                          fit: BoxFit.contain,
                                        )
                                      : (widget.data['payment_opt'] == '2')
                                          ? Image.asset(
                                              'assets/images/wallet.png',
                                              fit: BoxFit.contain,
                                            )
                                          : (widget.data['payment_opt'] == '0')
                                              ? Image.asset(
                                                  'assets/images/card.png',
                                                  fit: BoxFit.contain,
                                                )
                                              : Container(),
                                ),
                                SizedBox(
                                  width: mediaView.width * 0.01,
                                ),
                                Text(
                                  (widget.data['payment_opt'] == '1')
                                      ? languages[choosenLanguage]['text_cash']
                                      : (widget.data['payment_opt'] == '2')
                                          ? languages[choosenLanguage]
                                              ['text_wallet']
                                          : (widget.data['payment_opt'] == '0')
                                              ? languages[choosenLanguage]
                                                  ['text_card']
                                              : '',
                                  style: GoogleFonts.roboto(
                                      fontSize: mediaView.width * twelve,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '₹' +
                                        ' ' +
                                        (widget.data['total_amount'] ?? "0.00")
                                            .toString(),
                                    style: GoogleFonts.roboto(
                                        fontSize: mediaView.width * sixteen,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: mediaView.width * 0.01,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        (widget.data['total_time'] < 50)
                                            // ignore: prefer_interpolation_to_compose_strings
                                            ? widget.data['total_distance']
                                                    .toString() +
                                                "Km" +
                                                ' - ' +
                                                widget.data['total_time']
                                                    .toString() +
                                                ' mins'
                                            : widget.data['total_distance'] +
                                                widget.data['unit'] +
                                                ' - ' +
                                                (widget.data['total_time'] / 60)
                                                    .round()
                                                    .toString() +
                                                ' hr',
                                        style: GoogleFonts.roboto(
                                            fontSize: mediaView.width * twelve),
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
                      height: mediaView.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: mediaView.width * 0.05,
                          width: mediaView.width * 0.05,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xffFF0000).withOpacity(0.3)),
                          child: Container(
                            height: mediaView.width * 0.025,
                            width: mediaView.width * 0.025,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffFF0000)),
                          ),
                        ),
                        SizedBox(
                          width: mediaView.width * 0.05,
                        ),
                        SizedBox(
                            width: mediaView.width * 0.5,
                            child: Text(
                              widget.data['pick_address'],
                              style: GoogleFonts.roboto(
                                  fontSize: mediaView.width * twelve),
                            )),
                        if (widget.data['trip_start_time'] != null)
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.data['trip_start_time']
                                    .toString()
                                    .substring(11, 16),
                                style: GoogleFonts.roboto(
                                    fontSize: mediaView.width * twelve,
                                    color: const Color(0xff898989)),
                                textDirection: TextDirection.ltr,
                              )
                            ],
                          ))
                      ],
                    ),
                    if (widget.data['drop_address'] != null)
                      SizedBox(
                        height: mediaView.width * 0.05,
                      ),
                    if (widget.data['drop_address'] != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: mediaView.width * 0.05,
                            width: mediaView.width * 0.05,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xff319900).withOpacity(0.3)),
                            child: Container(
                              height: mediaView.width * 0.025,
                              width: mediaView.width * 0.025,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff319900)),
                            ),
                          ),
                          SizedBox(
                            width: mediaView.width * 0.05,
                          ),
                          SizedBox(
                              width: mediaView.width * 0.5,
                              child: Text(
                                widget.data['drop_address'] ?? "",
                                style: GoogleFonts.roboto(
                                    fontSize: mediaView.width * twelve),
                              )),
                          if (widget.data['trip_end_time'] != null)
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.data['trip_end_time']
                                      .toString()
                                      .substring(11, 16),
                                  // "Time here!",
                                  style: GoogleFonts.roboto(
                                      fontSize: mediaView.width * twelve,
                                      color: const Color(0xff898989)),
                                  textDirection: TextDirection.ltr,
                                )
                              ],
                            )),
                        ],
                      ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    //After accept, render this!
                    //change here!
                    ValueListenableBuilder<bool?>(
                        valueListenable: accepter,
                        builder: (context, value, snapshot) {
                          return (value != null
                              //  && widget.data['accepted_at'] != null
                              )
                              ? (value)
                                  ? Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TripChatPage(
                                                            id: widget.data[
                                                                'req_id'])));
                                          },
                                          child: Stack(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  SizedBox(
                                                    width: 30.0,
                                                    height: 30.0,
                                                    child: Image.asset(
                                                      "assets/images/message-square.png",
                                                      width: 30.0,
                                                      height: 30.0,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  const Text(
                                                    "Message",
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ValueListenableBuilder<int>(
                                                  valueListenable:
                                                      newMessagesCount,
                                                  builder: (context, value,
                                                      snapshot) {
                                                    return (value != 0)
                                                        ? Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Text(
                                                                "$value",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox();
                                                  }),
                                              // Positioned(
                                              //   top: 0,
                                              //   right: 0,
                                              //   child: FutureBuilder<int?>(
                                              //       future: getMessagesCount(),
                                              //       builder:
                                              //           (context, snapshot) {
                                              //         if (snapshot
                                              //                 .connectionState ==
                                              //             ConnectionState
                                              //                 .done) {
                                              //           if (snapshot.hasData) {
                                              //             if (snapshot.data !=
                                              //                     0 &&
                                              //                 snapshot.data !=
                                              //                     null) {
                                              //               return Container(
                                              //                 padding:
                                              //                     const EdgeInsets
                                              //                         .all(5.0),
                                              //                 decoration:
                                              //                     BoxDecoration(
                                              //                   color: Colors
                                              //                       .grey
                                              //                       .shade600,
                                              //                   shape: BoxShape
                                              //                       .circle,
                                              //                 ),
                                              //                 child: Text(
                                              //                   "${snapshot.data}",
                                              //                   style:
                                              //                       const TextStyle(
                                              //                     color: Colors
                                              //                         .white,
                                              //                   ),
                                              //                 ),
                                              //               );
                                              //             } else {
                                              //               return const SizedBox();
                                              //             }
                                              //           } else {
                                              //             return const SizedBox();
                                              //           }
                                              //         } else {
                                              //           return const SizedBox();
                                              //         }
                                              //       }),
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 5.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(5.0),
                                              )),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            makingPhoneCall(
                                                widget.data['mobile']);
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child: Image.asset(
                                                  "assets/images/Call.png",
                                                  width: 30.0,
                                                  height: 30.0,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              const Text(
                                                "Call",
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 5.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(5.0),
                                              )),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Image.asset(
                                              "assets/images/cancel.png",
                                              width: 30.0,
                                              height: 30.0,
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox()
                              : const SizedBox();
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool?>(
            valueListenable: accepter,
            builder: (context, value, snapshot) {
              return (value != null)
                  ? (value)
                      ? GestureDetector(
                          onTap: () {
                            requestReject();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: mediaView.width * 0.8,
                                  height: 50.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                    border: Border.all(
                                        width: 2.0, color: Colors.grey),
                                  ),
                                  child: Text(
                                    "Decline",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            requestAccept();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: mediaView.width * 0.8,
                                  height: 50.0,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  : const SizedBox();
            }),
      ),
    );
  }
}
