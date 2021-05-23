import 'package:flutter/material.dart';
import 'package:flutter2/application/raja_ongkir/raja_ongkir_cubit.dart';
import 'package:flutter2/domain/raja_ongkir/city/city_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/cost/cost_request_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/province/province_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/raja_ongkir_failed.dart';
import 'package:flutter2/injection.dart';
import 'package:flutter2/presentation/result/result_page.dart';
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
  final costCubit = getIt<RajaOngkirCubit>();

  final weightController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    provinceCubit.getProvinceDataFromInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Raja Ongkir")),
        body: BlocProvider(
          create: (context) => costCubit,
          child: BlocConsumer<RajaOngkirCubit, RajaOngkirState>(
              listener: (context, state) {
            state.maybeMap(
                orElse: () {},
                loading: (e) {
                  print("On Loading Get Cost");
                },
                error: (e) {
                  print(e);
                },
                onGetCostData: (e) {
                  Get.toNamed(ResultPage.TAG, arguments: e.responseDataModel);
                });
          }, builder: (context, state) {
            return Column(
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
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.toString().isEmpty)
                          return "Field can not be empty";
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                          hintText: "Weight", border: OutlineInputBorder()),
                    ),
                  ),
                ),
                state.maybeMap(
                  orElse: () => defaultButton(),
                  loading: (e) => loadingButton(),
                )
              ],
            );
          }),
        ));
  }

  Container defaultButton() {
    return Container(
      height: 45,
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          var _request = CostRequestDataModel(
              courier: "tiki,jne,pos", destination: 1, origin: 20, weight: 3000);
          costCubit.getCostDataFromInternet(_request);
        },
        child: Text("Get Ongkir"),
      ),
    );
  }

  Container loadingButton() {
    return Container(
      height: 45,
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
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
