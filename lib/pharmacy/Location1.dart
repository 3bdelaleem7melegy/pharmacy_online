// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_local_variable, file_names, library_private_types_in_public_api, unused_element, avoid_unnecessary_containers, prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pharmacy_online/model/pharmacymodel.dart';
import 'package:custom_text_form_field_plus/custom_text_form_field_plus.dart';

class Location1 extends StatefulWidget {
  const Location1({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Location1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _doctorName = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  int todayAppointmentsCount = 0;
  int allAppointmentsCount = 0;
  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    _doctorName = TextEditingController();
    _fetchAppointmentCounts();
  }

  @override
  void dispose() {
    _doctorName.dispose();
    super.dispose();
  }

  void _fetchAppointmentCounts() async {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);

    // Fetch today's appointments count
    QuerySnapshot todaySnapshot = await FirebaseFirestore.instance
        .collection('Pharmacy')
        // .doc("Cholestrol")
        // .collection("all")
        .where('type', isEqualTo: 'Location1')
        .where('day', isEqualTo: date)
        .get();
    setState(() {
      todayAppointmentsCount = todaySnapshot.size;
    });

    // Fetch all appointments count
    QuerySnapshot allSnapshot = await FirebaseFirestore.instance
        .collection('Pharmacy')
        // .doc("Cholestrol")
        // .collection("all")
        .where('type', isEqualTo: 'Location1')
        // .where('day', isEqualTo: day)
        .get();
    setState(() {
      allAppointmentsCount = allSnapshot.size;
    });
  }

  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    late String _message;
    DateTime now = DateTime.now();
    String _currentHour = DateFormat('kk').format(now);
    int hour = int.parse(_currentHour);
    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(
      () {
        if (hour >= 5 && hour < 12) {
          _message = 'Good Morning';
        } else if (hour >= 12 && hour <= 17) {
          _message = 'Good Afternoon';
        } else {
          _message = 'Good Evening';
        }
      },
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/DoctorProfile');
              },
              icon: Icon(
                Icons.people,
                size: 30,
              ),
            )
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Padding(padding: EdgeInsets.only(top: 20))
                Container(
                  // width: MediaQuery.of(context).size.width/1.3,
                  alignment: Alignment.center,
                  child: Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),

                const SizedBox(
                  width: 55,
                ),

                // IconButton(
                //   splashRadius: 20,
                //   icon: const Icon(Icons.notifications_active),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //         builder: (contex) => const NotificationList()));
                //   },
                // ),
              ],
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Today($todayAppointmentsCount)'),
              Tab(text: 'All($allAppointmentsCount)'),
              // Tab(text: 'Filter'),
              // Tab(text: 'Heart Test'),
            ],
          ),
        ),
        body: TabBarView(children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Pharmacy')
                // .doc(doctor!.Special)
                // .collection("Pending")
                .where('type', isEqualTo: 'Location1')
                .where('day', isEqualTo: day)
                .snapshots(),
            builder: (context, snapshot) {
              //log(snapshot.data!.docs.map((e) => e.data()).toString());
              // log(snapshot.data!.docs.map((e) => e.data()).toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'There is no treatment prescription',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  final data = snapshot.data!.docs
                      .map((e) => Pharmacy.formJson(e.data()))
                      .toList();
                  log(data.map((e) => e.toFireStore()).toString());

                  log(data.length.toString());
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 100),
                        child: Text(
                          "Hello  ${user.displayName}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'There is no treatment prescription',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(child: AppointmentsWidgetList(pharmacy: data)),
                    ],
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Pharmacy')
                // .doc(doctor!.Special)
                // .collection("Pending")
                .where('type', isEqualTo: 'Location1')
                .where('day', isEqualTo: selectedDate)
                .snapshots(),
            builder: (context, snapshot) {
              //log(snapshot.data!.docs.map((e) => e.data()).toString());
              // log(snapshot.data!.docs.map((e) => e.data()).toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  // return Center(
                  //     child: Text(
                  //   'There is no treatment prescription',
                  //   style: TextStyle(fontSize: 30),
                  //   textAlign: TextAlign.center,
                  // ));
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025),
                          ).then((value) {
                            if (value != null) {
                              final val =
                                  DateFormat('yyyy-MM-dd').format(value);

                              setState(() {
                                selectedDate = val;
                              });
                            }
                            log(value!.toString());
                          }).catchError((err) {
                            log(err.toString());
                          });
                        },
                        child: Text('Select Date'),
                      ),
                      const Center(
                          child: Text(
                        'There is no treatment prescription',
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                      )),
                    ],
                  );
                } else {
                  final data = snapshot.data!.docs
                      .map((e) => Pharmacy.formJson(e.data()))
                      .toList();
                  log(data.map((e) => e.toFireStore()).toString());

                  log(data.length.toString());
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 100),
                        child: Text(
                          "Hello  ${user.displayName}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Treatments Prescriptions',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025),
                          ).then((value) {
                            if (value != null) {
                              final val =
                                  DateFormat('yyyy-MM-dd').format(value);

                              setState(() {
                                selectedDate = val;
                              });
                            }
                            log(value!.toString());
                          }).catchError((err) {
                            log(err.toString());
                          });
                        },
                        child: Text('Select Date'),
                      ),
                      Expanded(child: AppointmentsWidgetList(pharmacy: data)),
                    ],
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
        ]),
      ),
    );
  }
}

String convertDate(String date) {
  final d = DateTime.parse(date);
  // final dateString = DateFormat.yMMMd().parse(date);
  return d.toString();
}

class AppointmentsWidgetList extends StatelessWidget {
  const AppointmentsWidgetList({super.key, required this.pharmacy});
  final List<Pharmacy> pharmacy;

  @override
  Widget build(BuildContext context) {
    log(pharmacy.map((e) => e.id).toString());

    return ListView.separated(
      separatorBuilder: (context, i) => SizedBox(
        height: 0,
      ),
      itemCount: pharmacy.length,
      itemBuilder: (context, i) => Column(
        children: [
          Container(
              padding: const EdgeInsets.only(),
              child: Form(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 9,
                  ),
                  CustomTextFormField(
                    hintText: pharmacy[i].day,
                  ),
                  CustomTextFormField(
                    hintText: pharmacy[i].doctorname,
                  ),
                  CustomTextFormField(
                    hintText: pharmacy[i].patient.id,
                  ),
                  CustomTextFormField(
                    hintText: pharmacy[i].patient.name,
                  ),
                  CustomTextFormField(
                    maxLines: 10,
                    hintText: pharmacy[i].description,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                ],
              ))),
        ],
      ),
    );

    // Text(appointments[index].patient.name),
    // Text(convertDate(appointments[index].date)),
    // Text(convertDate(appointments[index].date)),
    //     ],
    //   ),
    //  );
  }
}
