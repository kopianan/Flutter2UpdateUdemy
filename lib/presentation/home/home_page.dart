import 'package:flutter/material.dart';
import 'package:flutter2/application/raja_ongkir/raja_ongkir_cubit.dart';
import 'package:flutter2/domain/raja_ongkir/province/province_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/raja_ongkir_failed.dart';
import 'package:flutter2/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  static final String TAG = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final rajaOngkirCubit = getIt<RajaOngkirCubit>();

  @override
  void initState() {
    rajaOngkirCubit.getProvinceDataFromInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Raja Ongkir")),
        body: BlocProvider(
          create: (context) => rajaOngkirCubit,
          child: BlocConsumer<RajaOngkirCubit, RajaOngkirState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                loading: (e) {
                  print("IS LOADING");
                },
                error: (e) {
                  Get.showSnackbar(GetBar(
                    message: e.failed.description,
                    snackPosition: SnackPosition.TOP,
                    duration: Duration(seconds: 2),
                  ));
                },
                onGetProvinceData: (e) {
                  print(e.dataModel);
                },
              );
            },
            builder: (context, state) {
              return state.maybeMap(
                  orElse: () => Container(),
                  loading: (e) => Center(child: CircularProgressIndicator()),
                  error: (e) => errorWidget(e.failed),
                  onGetProvinceData: (value) => ProvinceDropdown(
                        data: value.dataModel,
                      ));
            },
          ),
        ));
  }
}

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({Key? key, required this.data}) : super(key: key);

  final List<ProvinceDataModel> data;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: DropdownButtonFormField<ProvinceDataModel>(
        items: data
            .map((e) => DropdownMenuItem(
                  child: Text(e.province),
                  value: e,
                ))
            .toList(),
        value: null,
        onChanged: (e){
          print(e);
        },
        decoration: InputDecoration(
            hintText: "Province",
            border: OutlineInputBorder(),),
      ),
    );
  }
}

Widget errorWidget(RajaOngkirFailed failed) => Center(
        child: Text(
      failed.description,
      style: TextStyle(fontSize: 29),
    ));
