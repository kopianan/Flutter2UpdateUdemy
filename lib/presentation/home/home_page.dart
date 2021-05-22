import 'package:flutter/material.dart';
import 'package:flutter2/application/raja_ongkir/raja_ongkir_cubit.dart';
import 'package:flutter2/domain/raja_ongkir/city/city_data_model.dart';
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
  final provinceCubit = getIt<RajaOngkirCubit>();
  final cityCubit = getIt<RajaOngkirCubit>();

  @override
  void initState() {
    provinceCubit.getProvinceDataFromInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Raja Ongkir")),
        body: Column(
          children: [
            BlocProvider(
              create: (context) => provinceCubit,
              child: BlocConsumer<RajaOngkirCubit, RajaOngkirState>(
                  listener: rajaOngkirListner,
                  builder: (context, state) =>
                      provinceCubitBuilder(context, state)),
            ),
            BlocProvider(
              create: (context) => cityCubit,
              child: BlocConsumer<RajaOngkirCubit, RajaOngkirState>(
                  listener: rajaOngkirListner,
                  builder: (context, state) =>
                      cityCubitBuilder(context, state)),
            ),
          ],
        ));
  }

  rajaOngkirListner(BuildContext context, RajaOngkirState state) {
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
        onGetCityData: (e) {
          print(e);
        });
  }

  provinceCubitBuilder(BuildContext context, RajaOngkirState state) {
    return state.maybeMap(
        orElse: () => defaultDropDown(),
        loading: (e) => loadingDropdown(),
        error: (e) => errorWidget(e.failed),
        onGetProvinceData: (value) =>
            ProvinceDropdown(data: value.dataModel, cubit: cityCubit));
  }

  cityCubitBuilder(BuildContext context, RajaOngkirState state) {
    return state.maybeMap(
        orElse: () => defaultDropDown(),
        loading: (e) => loadingDropdown(),
        error: (e) => errorWidget(e.failed),
        onGetCityData: (e) => CityDropdown(data: e.dataModel));
  }

  Container loadingDropdown() {
    return Container(
      padding: EdgeInsets.all(10),
      child: DropdownButtonFormField<CityDataModel>(
        items: [],
        value: null,
        decoration: InputDecoration(
            hintText: "Getting data ...",
            border: OutlineInputBorder(),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            )),
      ),
    );
  }

  Container defaultDropDown() {
    return Container(
      padding: EdgeInsets.all(10),
      child: DropdownButtonFormField<CityDataModel>(
        items: [],
        value: null,
        decoration: InputDecoration(
          hintText: "No Data",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({
    Key? key,
    required this.data,
    required this.cubit,
  }) : super(key: key);

  final List<ProvinceDataModel> data;
  final RajaOngkirCubit cubit;
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
        onChanged: (e) {
          print(e);
          cubit.getCityDataFromInternet(e!.provinceId);
        },
        decoration: InputDecoration(
          hintText: "Province",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class CityDropdown extends StatelessWidget {
  const CityDropdown({Key? key, required this.data}) : super(key: key);

  final List<CityDataModel> data;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: DropdownButtonFormField<CityDataModel>(
        items: data
            .map((e) => DropdownMenuItem(
                  child: Text(e.cityName),
                  value: e,
                ))
            .toList(),
        value: null,
        onChanged: (e) {
          print(e);
        },
        decoration: InputDecoration(
          hintText: "City",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

Widget errorWidget(RajaOngkirFailed failed) => Center(
        child: Text(
      failed.description,
      style: TextStyle(fontSize: 29),
    ));
