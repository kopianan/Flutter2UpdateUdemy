import 'package:bloc/bloc.dart';
import 'package:flutter2/domain/raja_ongkir/city/city_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/province/province_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/raja_ongkir_failed.dart';
import 'package:flutter2/domain/raja_ongkir/raja_ongkir_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'raja_ongkir_state.dart';
part 'raja_ongkir_cubit.freezed.dart';

@injectable
class RajaOngkirCubit extends Cubit<RajaOngkirState> {
  RajaOngkirCubit(this._iRajaOngkir) : super(RajaOngkirState.initial());

  IRajaOngkir _iRajaOngkir;

  void getProvinceDataFromInternet() async {
    emit(RajaOngkirState.loading());
    try {
      final _result = await _iRajaOngkir.getProvinceData();
      _result.fold(
        (l) => emit(RajaOngkirState.error(l)),
        (r) => emit(RajaOngkirState.onGetProvinceData(r)),
      );
    } catch (e) {
      emit(RajaOngkirState.error(
          RajaOngkirFailed().copyWith(description: e.toString())));
    }
  }

  void getCityDataFromInternet(String provinceId) async {
    emit(RajaOngkirState.loading());
    try {
      final _result = await _iRajaOngkir.getCityData(provinceId);
      _result.fold(
        (l) => emit(RajaOngkirState.error(l)),
        (r) => emit(RajaOngkirState.onGetCityData(r)),
      );
    } catch (e) {
      emit(RajaOngkirState.error(
          RajaOngkirFailed().copyWith(description: e.toString())));
    }
  }
}
