import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter2/domain/raja_ongkir/province/province_data_model.dart';
import 'package:flutter2/domain/raja_ongkir/raja_ongkir_failed.dart';
import 'package:flutter2/utils/constants.dart';
import 'package:injectable/injectable.dart';

abstract class IRajaOngkir {
  Future<Either<RajaOngkirFailed, List<ProvinceDataModel>>> getProvinceData();
}

@LazySingleton(as: IRajaOngkir)
class RajaOngkirRepository extends IRajaOngkir {
  Dio _dio = Dio();

  @override
  Future<Either<RajaOngkirFailed, List<ProvinceDataModel>>>
      getProvinceData() async {
    Response response;

    _dio =
        Dio(BaseOptions(headers: {"key": "d3378ccdaa201c0b0bffbd673aab43c2"}));
    try {
      response =
          await _dio.get(Constants.rajaOngkirBaseUrl + "starter/province");
      List<dynamic> _listData = response.data['rajaongkir']['results'];

      var _listResult = _listData
          .map((result) => ProvinceDataModel.fromJson(result))
          .toList();

      return right(_listResult);
    } on DioError catch (err) {
      if (err.type == DioErrorType.response) {
        var _errorData = err.response!.data['rajaongkir']['status'];
        var _errorModel = RajaOngkirFailed.fromJson(_errorData);
        return left(_errorModel);
      }
      return left(RajaOngkirFailed());
    }
  }
}
