import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phcapp/src/blocs/blocs.dart';
import 'package:phcapp/src/models/phc.dart';
import 'package:phcapp/src/providers/cpr_provider.dart';
// import 'package:phcapp/src/ui/tabs/patient/cpr_timelog.dart';
import 'package:provider/provider.dart';

import '../cpr/cpr_items.dart';
import '../cpr/cpr_timelog.dart';

// import 'cpr_items.dart';

enum ButtonAction { create, edit }

class CPRDetail extends StatefulWidget {
  final index;
  final CprSection cprSection;

  CPRDetail({this.index, this.cprSection});

  _CPRDetail createState() => _CPRDetail();
}

class _CPRDetail extends State<CPRDetail> {
  // @override
  // void didChangeDependencies() {

  //   final cprProvider = Provider.of<CPRProvider>(context);
  //   if (widget.cprSection != null) {
  //     cprProvider.setLogs(widget.cprSection.logs);
  //   }

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final cprBloc = BlocProvider.of<CprBloc>(context);

    // final cprProvider = Provider.of<CPRProvider>(context);
    // cprProvider.setLogs(widget.cprSection.logs);

    _buildButton1(context) {
      final cprProvider = Provider.of<CPRProvider>(context);

      if (widget.index == null) {
        // new cpr
        return FlatButton(
          child: Text(
            "CREATE",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            CprSection cpr = new CprSection(
                timestamp:
                    DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()),
                witnessCpr: cprProvider.getValue("witness_cpr"),
                bystanderCpr: cprProvider.getValue("bystander_cpr"),
                rosc: cprProvider.getValue("rosc"),
                cprStart: cprProvider.getValue("cpr_start"),
                cprStop: cprProvider.getValue("cpr_stop"),
                shockable: Analysis(
                  rhythm: cprProvider.getValue("srhythm"),
                  intervention: cprProvider.getValue("sinterv"),
                  drugs: cprProvider.getValue("sdrugs"),
                  airway: cprProvider.getValue("sairway"),
                ),
                nonShockable: Analysis(
                  rhythm: cprProvider.getValue("nsrhythm"),
                  intervention: cprProvider.getValue("nsinterv"),
                  drugs: cprProvider.getValue("nsdrugs"),
                  airway: cprProvider.getValue("nsairway"),
                ),
                other: Analysis(
                  rhythm: cprProvider.getValue("orhythm"),
                  intervention: cprProvider.getValue("ointerv"),
                  drugs: cprProvider.getValue("odrugs"),
                  airway: cprProvider.getValue("oairway"),
                ),
                // cprProvider.getAnalysis("shockable"),
                // nonShockable: cprProvider.getAnalysis("non_shockable"),
                // other: cprProvider.getAnalysis('other'),
                logs: cprProvider.allLogs);

            print(cpr.toJson());
            cprBloc.add(AddCpr(cprSection: cpr));
            // provider.addCPR(cpr);
            // print("CURRENT LIST CPRS");
            // print(provider.listCPRs.length);
            Navigator.pop(context);
          },
        );
      }
      return Container();
      // else {
      //   return FlatButton(
      //     child: Text(
      //       "SAVE",
      //       style: TextStyle(color: Colors.white),
      //     ),
      //     onPressed: () {},
      //   );
      // }
    }

    _buildButton2() {
      if (widget.index == null) {
        return FlatButton(
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        );
      } else {
        return FlatButton(
          child: Text(
            "DELETE",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            cprBloc.add(RemoveCpr(index: widget.index));
            Navigator.pop(context);
          },
        );
      }
    }

    return ChangeNotifierProvider(
        create: (context) => CPRProvider(),
        child: DefaultTabController(
            length: 2,
            child:
                Consumer<CPRProvider>(builder: (context, cprProvider, child) {
              // // final cprProvider = Provider.of<CPRProvider>(context);
              if (widget.cprSection != null) {
                print("THIS IS NOT EMPTY CPR");
                print(widget.cprSection.toJson());
                final cpr = widget.cprSection;
                cprProvider.updateValue("witness_cpr", cpr.witnessCpr);
                cprProvider.updateValue("bystander_cpr", cpr.bystanderCpr);
                cprProvider.updateValue("cpr_stop", cpr.cprStop);
                cprProvider.updateValue("cpr_start", cpr.cprStart);
                cprProvider.updateValue("rosc", cpr.rosc);
                cprProvider.updateValue("sryhthm", cpr.shockable.rhythm);
                cprProvider.updateValue("sinterv", cpr.shockable.intervention);
                cprProvider.updateValue("sdrugs", cpr.shockable.drugs);
                cprProvider.updateValue("sairway", cpr.shockable.airway);
                cprProvider.updateValue("nsryhthm", cpr.nonShockable.rhythm);
                cprProvider.updateValue(
                    "nsinterv", cpr.nonShockable.intervention);
                cprProvider.updateValue("nsdrugs", cpr.nonShockable.drugs);
                cprProvider.updateValue("nsairway", cpr.nonShockable.airway);
                cprProvider.updateValue("oryhthm", cpr.other.rhythm);
                cprProvider.updateValue("ointerv", cpr.other.intervention);
                cprProvider.updateValue("odrugs", cpr.other.drugs);
                cprProvider.updateValue("oairway", cpr.other.airway);

                cprProvider.setLogs(widget.cprSection.logs);

                // setState(() {});
              }

              // cprProvider.setLogs(logs)

              return Scaffold(
                  appBar: AppBar(
                    title: (widget.index != null)
                        ? Text("CPR Detail (readonly)")
                        : Text("CPR Detail"),
                    bottom: TabBar(tabs: [
                      Tab(icon: Icon(Icons.airline_seat_flat_angled)),
                      Tab(icon: Icon(Icons.alarm)),
                    ]),
                    actions: <Widget>[_buildButton2(), _buildButton1(context)],
                  ),
                  body: TabBarView(children: <Widget>[
                    CPRItems(
                        // cprSection: widget.cprSection,
                        ),
                    CPRTimeLog(
                      index: widget.index,
                      // cprSection: widget.cprSection,
                      // cpr
                    )
                  ]));
            })));
  }

}
