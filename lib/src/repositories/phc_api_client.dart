import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:phcapp/src/models/phc.dart';

class PhcApiClient {
  static const baseUrl = "http://202.171.33.109/phc-mobile/api/v1";
  final http.Client httpClient;

  PhcApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future fetchPhc() async {
    final phcUrl = '$baseUrl/callcards';
    final phcResponse = await this.httpClient.get(phcUrl);

    if (phcResponse.statusCode != 200) {
      throw Exception("Error getting phc dataset from server");
    }
    // print("we are here in fetchPhc function");
    // final phcJson = jsonDecode(phcResponse.body);
    // final phcJson = json.decode(phcResponse.body);
    // print("HAJI");
    // print(phcJson.callcards[0].callInformation.callcardNo);
    print("OOuuuww.. cannot decode data");
    // return phcResponse.body;
    final phcJson = jsonDecode(phcResponse.body);
    return phcJson;
  }

  Future postCallcard(Callcard callcard) async {
    assert(callcard != null);

    print("post callcard masuk");
    print(jsonEncode(callcard.callInformation));
    // print(jsonEncode(callcard.scene_assessment));

    var internal_callcard = {};
    internal_callcard["call_information"] = callcard.callInformation;
    internal_callcard["response_team"] = callcard.responseTeam;
    internal_callcard["response_time"] = callcard.responseTime;
    internal_callcard["scene_assessment"] = callcard.sceneAssessment;
    internal_callcard["patients"] = callcard.patients;
    final postResponse = await this.httpClient.post(
        "$baseUrl/upload_result/call_card",
        body: jsonEncode(internal_callcard));

    print("post-status-code:");
    print(postResponse.statusCode);
    // if (postResponse.statusCode == 200) {
    //   print("masuk dalam 200");
    //   final resultResponse = jsonDecode(postResponse.body);
    //   print("result response");
    //   print(resultResponse);
    //   // return Callcard.fromJson(resultResponse);
    //   return resultResponse;
    // } else {
    if (postResponse.statusCode != 200) {
      print("htrow excemptions");
      throw Exception("Failed to post call card");
    }

    print("Lepas throw");
    final callcardJson = jsonDecode(postResponse.body);
    print(callcardJson);
    return callcardJson;
    // return Callcard.fromJson(callcardJson);
  }

  Future fetchAvailableStaffs() async {
    final phcUrl = '$baseUrl/available_staffs';
    final phcResponse = await this.httpClient.get(phcUrl);

    if (phcResponse.statusCode != 200) {
      throw Exception("Error getting phc dataset from server");
    }
    final phcJson = jsonDecode(phcResponse.body);
    return phcJson;
  }
}
