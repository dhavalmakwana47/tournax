import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  ProfileRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      appLogger.d('Profile raw response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return ProfileModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Profile parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(ApiConstants.profile, data: data);
      appLogger.d('Profile update response: $response');
      final responseData = response['data'] as Map<String, dynamic>?;
      if (responseData == null) throw ApiException.unexpected();
      return ProfileModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Profile update error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
