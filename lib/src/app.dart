import 'package:flutter/material.dart';
import 'package:phcapp/src/blocs/blocs.dart';
// import 'package:phcapp/src/blocs/cpr_bloc.dart';
import 'package:phcapp/src/database/phc_dao.dart';
import 'package:phcapp/src/repositories/repositories.dart';
import 'package:phcapp/src/ui/list_callcard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phcapp/src/ui/login.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/intervention_bloc.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/medication_bloc.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/outcome_bloc.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/pat_ass_bloc.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/reporting_bloc.dart';
import 'package:phcapp/src/ui/tabs/patient/asessments/blocs/trauma_bloc.dart';
import 'package:phcapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class App extends StatelessWidget {
  final PhcRepository phcRepository =
      PhcRepository(phcApiClient: PhcApiClient(httpClient: http.Client()));

  final PhcDaoClient phcDaoClient = new PhcDaoClient(phcDao: new PhcDao());
  // final phcDao = new PhcDao();

  @override
  build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MultiBlocProvider(
        // BlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PhcBloc(
                  phcRepository: phcRepository, phcDao: phcDaoClient.phcDao)),
          BlocProvider<AuthBloc>(create: (context) {
            return AuthBloc(phcRepository: phcRepository)..add(AppStarted());
          }),
          BlocProvider(
              create: (context) =>
                  LoginBloc(authBloc: BlocProvider.of<AuthBloc>(context))),
          BlocProvider(
            create: (context) => CallInfoBloc(),
          ),
          BlocProvider(
              create: (context) => TeamBloc(phcDao: phcDaoClient.phcDao)),
          BlocProvider(
              create: (context) => StaffBloc(
                  phcRepository: phcRepository, phcDao: phcDaoClient.phcDao)),
          BlocProvider(
              create: (context) => TimeBloc(phcDao: phcDaoClient.phcDao)),
          BlocProvider(
              create: (context) => PatientBloc(phcDao: phcDaoClient.phcDao)),
          BlocProvider(
              create: (context) => VitalBloc(phcDao: phcDaoClient.phcDao)),
          BlocProvider(
              create: (context) => HistoryBloc(
                    phcDao: phcDaoClient.phcDao,
                  )),
          BlocProvider(
              create: (context) => CallCardTabBloc(
                  phcDao: phcDaoClient.phcDao,
                  phcRepository: phcRepository,
                  historyBloc: BlocProvider.of<HistoryBloc>(context))),
          BlocProvider(create: (context) => InterBloc()),
          BlocProvider(
            create: (context) => CprBloc(),
          ),
          BlocProvider(
            create: (context) => ResponseBloc(),
          ),
          BlocProvider(
            create: (context) => SceneBloc(),
          ),
          BlocProvider(
            create: (context) => TraumaBloc(),
          ),
          BlocProvider(
            create: (context) => AssPatientBloc(),
          ),
          BlocProvider(
            create: (context) => MedicationBloc(),
          ),
          BlocProvider(
            create: (context) => ReportingBloc(),
          ),
          BlocProvider(
            create: (context) => OutcomeBloc(),
          ),
        ],
        child: MaterialApp(
            theme: themeProvider.getThemeData,
            // home: ListCallcards(phcDao: phcDaoClient.phcDao),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                // if (state is AuthUnitialized) {

                if (state is AuthAunthenticated) {
                  return ListCallcards();
                } else if (state is AuthInitialized) {
                  return LoginScreen();
                } else if (state is AuthUnaunthenticated) {
                  return LoginScreen();
                }
                //  else if (state is AuthLoading) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8,
                            0.0), // 10% of the width, so there are ten blinds.
                        colors: [
                          const Color(0xFF33ccff),
                          const Color(0xFFff99cc)
                        ], // whitish to gray
                        tileMode: TileMode
                            .mirror, // repeats the gradient over the canvas
                      ),
                    ),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300,
                              child: Image(
                                  image: AssetImage('assets/ambulance.png')),
                            ),
                            Text(
                              "PH Care",
                              style: TextStyle(
                                  fontFamily: "OpenSans",
                                  fontWeight: FontWeight.w900,
                                  fontSize: 40,
                                  letterSpacing: 2.0),
                            ),
                            Text(
                              "Pre Hospital Care",
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  letterSpacing: 3.0),
                            ),
                            SizedBox(
                              height: 100,
                            ),
                            Container(
                              width: double.infinity,
                              height: 100,
                              child: Image(image: AssetImage('assets/kkm.png')),
                            ),
                          ]),
                    ),
                  ),
                );
                // return Container();
              },
            )));
  }
}
