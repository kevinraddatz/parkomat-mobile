import 'package:dio/dio.dart' show Dio, RequestOptions, Response;
import 'package:parkomat/data/network/apis/parkomat/parkomat_client.dart' show ParkomatClient;
import 'package:parkomat/models/parkomat/free_spot_statistics.dart' show FreeSpotStatistics;

class ParkomatCoreClient extends ParkomatClient {
  ParkomatCoreClient(this._dio) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final String _prefix = "core";

  String get prefix => _prefix;
  final Dio _dio;

  String baseUrl;

  Future<FreeSpotStatistics> getStats(String baseUrl) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/stats',
      options: RequestOptions(
        baseUrl: baseUrl,
      ),
    );
    return FreeSpotStatistics.fromJson(_result.data);
  }

  Future<dynamic> getHealth(String baseUrl) async {
    return _dio.get(
      '/health',
      options: RequestOptions(
        baseUrl: baseUrl,
      ),
    );
  }
}
