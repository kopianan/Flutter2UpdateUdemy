import 'package:flutter/material.dart';
import 'package:flutter2/domain/raja_ongkir/city/city_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/cost/cost_response_data_model.dart';
import 'package:get/get.dart';

class ResultPage extends StatefulWidget {
  static final String TAG = '/result_page';
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late CostResponseDataModel response;

  @override
  void initState() {
    response = Get.arguments as CostResponseDataModel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //origin
          cityListTile(
            response.originDetails,
            Colors.green[200],
            "Asal Kota",
          ),
          //desitination
          cityListTile(
            response.destinationDetails,
            Colors.red[200],
            "Tujuan Kota",
          ),

          Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                response.results.first.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),

          Expanded(
            child: ListView.builder(
                itemCount: response.results.first.costs.length,
                itemBuilder: (context, index) {
                  var _cost = response.results.first.costs[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(_cost.service),
                        subtitle: Text(_cost.description),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _cost.cost.first.value.toString(),
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(_cost.cost.first.etd.toString() + " Hari"),
                          ],
                        ),
                      ),
                      Divider()
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }

  ListTile cityListTile(CityDataModel? city, Color? color, String title) {
    return ListTile(
      tileColor: color,
      title: Text(title),
      subtitle: Text(city!.cityName),
    );
  }
}
