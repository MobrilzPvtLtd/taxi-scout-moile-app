import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';

import '../../translation/translation.dart';
import '../../widgets/widgets.dart';

ValueNotifier<String> activePackage = ValueNotifier<String>("");

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  bool _isLoading = true;

  ValueNotifier<int> selectedPackage = ValueNotifier<int>(100);
  ValueNotifier<String> selectedPlanId = ValueNotifier<String>("0");
  String selectedPlanCharge = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getpackages();
    });
  }

  getpackages() async {
    await getWalletHistory();
    await getVipPackages();
    if (mounted) {
      print("Here==========================>");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Bearer Token: ${bearerToken[0].token}");
    print("${packages}");
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
        title: const Text("Subscriptions",
            style: TextStyle(
              color: Colors.black,
            )),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubscriptionDetail(
              isSubscribed: userDetails['is_vip_driver'] == "1",
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available plans:",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  (_isLoading)
                      ? Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.red.shade200,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text("Loading...",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.redAccent.shade200,
                                  ))
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: packages.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ValueListenableBuilder(
                                valueListenable: selectedPackage,
                                builder: (context, value, snapshot) {
                                  return ValueListenableBuilder<String>(
                                      valueListenable: activePackage,
                                      builder: (context, value2, snapshot) {
                                        return GestureDetector(
                                          onTap: () {
                                            selectedPackage.value = index;
                                            selectedPlanId.value =
                                                "${packages[index].id}";
                                            selectedPlanCharge =
                                                "${packages[index].charge}";
                                          },
                                          child: PackageItem(
                                            isActive:
                                                packages[index].title == value2,
                                            title: packages[index].title ?? "",
                                            description:
                                                packages[index].description ??
                                                    "",
                                            validity:
                                                packages[index].validity ?? 0,
                                            charge:
                                                (packages[index].charge ?? "")
                                                    .toString(),
                                            isSelected: (value == index),
                                          ),
                                        );
                                      });
                                });
                          })
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: selectedPlanId,
          builder: (context, value, snapshot) {
            return (value == "0")
                ? const SizedBox(
                    height: 1.0,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: Button(
                      onTap: () async {
                        if (!(double.parse(selectedPlanCharge) <
                            (walletBalance['wallet_balance']).toDouble())) {
                          //confirm
                          purchaseVIPPackage(selectedPlanId.value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Insufficient Amount in your wallet")));
                        }
                      },
                      text: languages[choosenLanguage]['text_purchase'],
                      width: media.width * 0.8,
                    ),
                  );
          }),
    );
  }
}

class SubscriptionDetail extends StatefulWidget {
  final bool isSubscribed;
  const SubscriptionDetail({Key? key, required this.isSubscribed})
      : super(key: key);

  @override
  State<SubscriptionDetail> createState() => _SubscriptionDetailState();
}

class _SubscriptionDetailState extends State<SubscriptionDetail> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.isSubscribed) {
        getSubDetail();
      }
    });
  }

  getSubDetail() async {
    await getSubscriptionDetails();
    activePackage.value = userSubscriptionDetail['title'];
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isSubscribed)
        ? (_isLoading)
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                height: MediaQuery.of(context).size.height * 0.3,
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Color(0xFF005e54),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text("Loading...Please wait!"),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  color: Colors.white,
                ),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      flex: 7,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "You are already\nSubscribed!",
                            style: TextStyle(
                              fontSize: 27.0,
                              color: Color.fromRGBO(184, 104, 104, 1),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Subscription Type:",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color.fromRGBO(102, 49, 49, 1),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                userSubscriptionDetail['title'],
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Color.fromRGBO(102, 49, 49, 1),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Last Purchase:",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color.fromRGBO(102, 49, 49, 1),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                "${userSubscriptionDetail['plandDate'].substring(8)} ${monthWidget(userSubscriptionDetail['plandDate'].substring(5, 7))}, ${userSubscriptionDetail['plandDate'].substring(0, 4)}",
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Color.fromRGBO(102, 49, 49, 1),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Subscription ends:",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color.fromRGBO(102, 49, 49, 1),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                "${userSubscriptionDetail['expiryDate'].substring(8)} ${monthWidget(userSubscriptionDetail['expiryDate'].substring(5, 7))}, ${userSubscriptionDetail['expiryDate'].substring(0, 4)}",
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Color.fromRGBO(102, 49, 49, 1),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [Image.asset("assets/images/diamond.png")],
                      ),
                    ),
                  ],
                ),
              )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.all(20.0),
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/diamond-inactive.png'),
                const Text("You're not subscribed to any plans.")
              ],
            ),
          );
  }

  monthWidget(String arg) {
    switch (arg) {
      case "01":
        return "Jan";
      case "02":
        return "Feb";
      case "03":
        return "Mar";
      case "04":
        return "Apr";
      case "05":
        return "May";
      case "06":
        return "Jun";
      case "07":
        return "Jul";
      case "08":
        return "Aug";
      case "09":
        return "Sep";
      case "10":
        return "Oct";
      case "11":
        return "Nov";
      case "12":
        return "Dec";
    }
  }
}

class PackageItem extends StatelessWidget {
  final bool isActive;
  final bool isSelected;
  final String title;
  final String description;
  final int validity;
  final String charge;

  const PackageItem(
      {Key? key,
      required this.isActive,
      required this.title,
      required this.description,
      required this.validity,
      required this.charge,
      required this.isSelected})
      : super(key: key);

  String capitalizeStringWithSpaces(String input) {
    var result = '';
    for (var i = 0; i < input.length; i++) {
      result += input[i].toUpperCase();
      if (i != input.length - 1) {
        result += ' ';
      }
    }
    return result;
  }

  String typeInfer(int arg) {
    if (arg == 1) return "Monthly";
    if (arg == 3) return "Quarterly";
    if (arg == 12) {
      return "Yearly";
    } else {
      return "Monthly";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: isSelected ? 4.0 : 2.0,
          color: isSelected ? const Color(0xFF007267) : const Color(0x99005e54),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  color: Colors.red.shade50,
                ),
                child: Text(
                  capitalizeStringWithSpaces(title),
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0x77FF0000),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "₹$charge/${typeInfer(validity)}",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF005e54),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xAA005e54),
                ),
              ),
            ],
          ),
          if (isActive)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  color: Color(0xBBFFCC08),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xFF009688),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubscriptionModel {
  int? id;
  String? title;
  int? charge;
  int? validity;
  String? description;
  String? createdAt;

  SubscriptionModel(
      this.id, this.title, this.charge, this.validity, this.createdAt);

  SubscriptionModel.fromJson(Map data)
      : id = data['id'],
        title = data['title'],
        charge = data['charge'],
        validity = data['validity'],
        description = data['description'],
        createdAt = data['created_at'];
}
