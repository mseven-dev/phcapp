import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phcapp/src/blocs/blocs.dart';
import 'package:phcapp/src/database/phc_dao.dart';
import 'package:phcapp/src/models/phc.dart';
import 'package:phcapp/src/providers/patinfo_provider.dart';
import 'package:phcapp/src/ui/history.dart';
import 'package:phcapp/src/ui/tabs/patient_list.dart';
import 'package:phcapp/src/ui/tabs/response_team.dart';
import 'package:phcapp/src/ui/tabs/response_time.dart';
import 'package:provider/provider.dart';
// import '../blocs/info_bloc.dart';
import 'package:phcapp/src/ui/tabs/call_information.dart';
import '../repositories/repositories.dart';

import 'package:http/http.dart' as http;
// import 'src/tab_screens/patients.dart';
// import 'src/tab_screens/information.dart';
// import 'src/tab_screens/team.dart';
// import 'src/tab_screens/timer.dart';
// import '../models/info_model.dart';
// import '../models/phc_model.dart';
// import '../models/team_model.dart';
// import '../models/timer_model.dart';
import '../models/phc.dart';
import 'list_callcard.dart';

class CallcardTabs extends StatefulWidget {
  final String callcard_no;
  final CallInformation call_information;
  final ResponseTeam response_team;
  final ResponseTime response_time;
  final List<Patient> patients;
  // final PhcDao phcDao;

  CallcardTabs({
    this.callcard_no,
    this.call_information,
    this.response_team,
    this.response_time,
    this.patients,
    // this.phcDao
  });

  _CallcardTabs createState() => _CallcardTabs();
}

class _CallcardTabs extends State<CallcardTabs> {
  CallInfoBloc callInfoBloc;

  final PhcRepository phcRepository =
      PhcRepository(phcApiClient: PhcApiClient(httpClient: http.Client()));
  // final PhcRepository phcRepository =
  //     PhcRepository(phcApiClient: PhcApiClient(httpClient: http.Client()));

  // final PhcDaoClient phcDaoClient = new PhcDaoClient(phcDao: new PhcDao());

  PhcBloc phcBloc;
  // CallcardTabs(
  //     {this.callcard_no,
  //     this.call_information,
  //     this.response_team,
  //     this.response_time,
  //     this.patients,
  //     this.phcDao});

  // @override

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // if (BlocProvider.of<TeamBloc>(context).response_team != null)
    //   print("dispose response team");
    // BlocProvider.of<TeamBloc>(context).response_team = new ResponseTeam();
    super.dispose();
  }

  showLoading() => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Callcard is Publishing..."),
            content: Center(
              child: CircularProgressIndicator(),
            ));
      });

  showError() => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Data sending failed"),
          content: Text(
              "Something went wrong. \nWe keep your last saving in History"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        );
      });

  savingError() => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Opss Saving failed"),
          content: Text("We couldn't save in History"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        );
      });

  showSuccess() => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Data sending successful",
            // style: TextStyle(fontSize: 14),
          ),
          content: Text("View transaction on History"),
          actions: <Widget>[
            FlatButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            FlatButton(
              child: Text("GOTO HISTORY"),
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => History()))
                    .then((result) {
                  Navigator.pop(context);
                });

                // Navigator.pop(context);
              },
            )
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        );
      });

  convertDateToStandard(String datetime) {
    if (datetime.contains("-") != true) {
      //dd/MM/yyyy HH:mm:ss to yyyy-MM-dd HH:mm:ss
      var split = datetime.split("/");
      var dd = split[0];
      var MM = split[1];
      var yyyy = split[2].substring(0, 4);

      var time = datetime.substring(11);

      print(time);
      return "$yyyy-$MM-$dd $time:00";
    } else {
      return datetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamBloc = BlocProvider.of<TeamBloc>(context);
    final timeBloc = BlocProvider.of<TimeBloc>(context);
    final patientBloc = BlocProvider.of<PatientBloc>(context);
    final tabBloc = BlocProvider.of<CallCardTabBloc>(context);
    final historyBloc = BlocProvider.of<HistoryBloc>(context);
    final callInfoBloc = BlocProvider.of<CallInfoBloc>(context);
    final responseBloc = BlocProvider.of<ResponseBloc>(context);
    final sceneBloc = BlocProvider.of<SceneBloc>(context);
    // var callcard = Provider.of<Callcard>(context);

    // callInfoBloc = BlocProvider.of<CallInfoBloc>(context);
    // var callInfoBloc = Provider.of<CallInfoBloc>(context);

    phcBloc = BlocProvider.of<PhcBloc>(context);

    return
        // MultiProvider(
        //     providers: [
        //       BlocProvider(create: (context) => TeamBloc(phcDao: new PhcDao())),
        //       // BlocProvider(
        //       //     create: (context) => StaffBloc(phcRepository: phcRepository))
        //     ],
        //     child:
        DefaultTabController(
            length: 4,
            child: BlocConsumer<CallCardTabBloc, TabState>(
              listener: (context, state) {
                if (state is CallcardToPublishLoading) {
                  //circular progress alert dialog
                  showLoading();
                } else if (state is CallcardToPublishSuccess) {
                  //Callcard success publish dialog with ok
                  showSuccess();
                } else if (state is CallcardToPublishFailed) {
                  //callcard failed to publish dialog error
                  showError();
                } else if (state is CallcardToSavingError) {
                  savingError();
                }
              },
              builder: (context, state) {
                return Scaffold(
                  // backgroundColor: Colors.white,
                  appBar: AppBar(
                    // shape: ShapeBorder(BorderRadius.only(topLeft:Radius.circular(2.0))),
                    // backgroundColor: Colors.white,
                    bottom: TabBar(
                      labelColor: Colors.pinkAccent,
                      unselectedLabelColor: Colors.white,

                      // indicatorPadding: EdgeInsets.symmetric(vertical: 40),
                      // indicatorWeight: 4.0,
                      // indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                          // border: Border.,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: Colors.white),

                      // unselectedLabelColor: Colors.red,
                      // labelColor: Colors.blue,
                      // indicatorColor: Color(0x880E4F00),
                      tabs: [
                        Tab(icon: Icon(Icons.info)),
                        Tab(icon: Icon(Icons.directions_car)),
                        Tab(icon: Icon(Icons.timer)),
                        Tab(icon: Icon(Icons.person)),
                      ],
                    ),
                    title: Center(
                        child: StreamBuilder(
                            initialData: widget.callcard_no != null
                                ? widget.callcard_no
                                : '',
                            stream: callInfoBloc.cardNoController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data,
                                    style: TextStyle(
                                        fontFamily: "OpenSans", fontSize: 20));
                              }
                              return Container();
                            })),

                    actions: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(40.0)),
                        padding: EdgeInsets.only(right: 10),
                        child:
                            // FlatButton.icon(

                            // )
                            Row(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.cloud_upload),
                              tooltip: "Push to Server",
                              onPressed: () {
                                print("callInfoBloc state push toserver");

                                final call_information =
                                    callInfoBloc.state.callInformation;
                                call_information.callReceived =
                                    convertDateToStandard(callInfoBloc
                                        .state.callInformation.call_received);

                                // print(currentState.toJson());
                                final response_team = new ResponseTeam(
                                    serviceResponse:
                                        responseBloc.state.serviceResponse,
                                    vehicleRegno:
                                        responseBloc.state.vehicleRegNo,
                                    staffs: teamBloc.state.selectedStaffs);
                                // print(teamState);

                                final response_time =
                                    timeBloc.state.responseTime;
                                // print(timeState);

                                final scene_assessment = new SceneAssessment(
                                    otherServicesAtScene:
                                        sceneBloc.state.selectedServices);
                                // print(patientState);
                                final patientList = patientBloc.state.patients;

                                // print(patientList.length);
                                // print(scene_assessment.toJson());
                                // print(patientList.elementAt(0).patientInformation.idNo);

                                // print(patientBloc.sceneAssessment.toJson());
                                // historyBloc.add(AddHistory(
                                //     callcard: new Callcard(
                                //         callInformation: call_information,
                                //         responseTeam: response_team,
                                //         responseTime: response_time,
                                //         patients: List<Patient>(),
                                //         sceneAssessment: new SceneAssessment())));

                                print("DONE");

                                tabBloc.add(PublishCallcard(
                                    callInformation: call_information,
                                    responseTeam: response_team,
                                    responseTime: response_time,
                                    sceneAssessment: scene_assessment,
                                    patients: patientList
                                    // responseTeam: response_team,
                                    // responseTime: response_time,
                                    // patients: patientList,
                                    // sceneAssessment:
                                    //     SceneAssessment(otherServicesAtScene: []
                                    //     )
                                    ));
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => History()));
                              },
                            ),
                            Text("UPLOAD")
                          ],
                        ),
                      ),
                    ],
                  ),
                  // backgroundColor: Colors.purple),
                  body:
                      // Consumer<CallInformation>(builder: (context, info, child) {
                      //   return
                      TabBarView(
                    children: <Widget>[
                      CallInformationScreen(
                          call_information: widget.call_information),
                      ResponseTeamScreen(
                          // context: context,
                          response_team: widget.response_team,
                          assign_id: (widget.call_information != null)
                              ? widget.call_information.assign_id
                              : null),
                      ResponseTimeScreen(
                        // responseTime: widget.response_time,
                        responseTime: widget.response_time != null
                            ? widget.response_time
                            : new ResponseTime(),
                        // assign_id: (widget.call_information != null)
                        //     ? widget.call_information.assign_id
                        //     : null
                      ),

                      PatientListScreen(
                        patients: widget.patients,
                        assign_id: (widget.call_information != null)
                            ? widget.call_information.assign_id
                            : null,
                      )
                      // Icon(Icons.ev_station),
                      // Icon(Icons.ev_station),
                      // Team(),
                      // Timer(),
                      // Patients(),
                    ],
                    // );
                    // }
                  ),
                );
              },
              // child:
            ));
    // );
  }

  // });
}
