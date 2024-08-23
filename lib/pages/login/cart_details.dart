import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class CarDetailscreen extends StatefulWidget {
  const CarDetailscreen({Key? key}) : super(key: key);

  @override
  State<CarDetailscreen> createState() => _CarDetailscreenState();
}

class _CarDetailscreenState extends State<CarDetailscreen> {

  @override
  void initState() {
    ischeckownerordriver = '';
    super.initState();
  }

  List<Map<String, dynamic>> itemList = [
    {
      'title': 'Car owner',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.star
    },
    {
      'title': 'Motorbike',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.favorite
    },
    {
      'title': 'Commercial',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.bookmark
    },
    {
      'title': 'Auto rickshaw',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.bookmark
    },
    {
      'title': 'Car owner',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.bookmark
    },
    {
      'title': 'Motorbike',
      'description':
          'You have a car that you wish to drive or emplo others to drive',
      'icon': Icons.bookmark
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 7.0, right: 7.0, top: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Choose how you want to earn with TaxiCout24',
                      style: GoogleFonts.roboto(
                          fontSize: media.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                ischeckownerordriver = item['title'];
                              });
                            },
                            child: Container(
                              height: media.width * 0.4,
                              // width: media.width * 0.8,
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: page,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0),
                                    blurRadius: 5.0,
                                  ),
                                ],
                                border: ischeckownerordriver == item['title']
                                    ? Border.all(color: buttonColor, width: 3)
                                    : null,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: media.width * 0.1,
                                          width: media.width * 0.2,
                                          margin: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.8),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "Rides",
                                                style: GoogleFonts.roboto(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: media.width * 0.04,
                                        ),
                                        Container(
                                          height: media.width * 0.1,
                                          width: media.width * 0.2,
                                          margin: EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.transform_sharp,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "Fleet",
                                                style: GoogleFonts.roboto(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: media.width * 0.09,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(item['title']),
                                              Spacer(),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                height: media.width * 0.12,
                                                width: media.width * 0.12,
                                                decoration: BoxDecoration(
                                                  color: page,
                                                  shape: BoxShape.circle,
                                                  image: const DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/cardriver.png'),
                                                      fit: BoxFit.contain),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 5.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(item['description']),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            ischeckownerordriver != ''
                ? Container(
                    padding: EdgeInsets.all(media.width * 0.05),
                    child: Button(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Maps()));
                        },
                        text: languages[choosenLanguage]['text_continue']),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
