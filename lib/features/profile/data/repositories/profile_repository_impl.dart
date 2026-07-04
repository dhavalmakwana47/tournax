import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final ProfileRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<ProfileEntity> getProfile() async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.getProfile();
    return _toEntity(model);
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? email,
    String? username,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
    };
    final model = await remoteDatasource.updateProfile(data);
    return _toEntity(model);
  }

  ProfileEntity _toEntity(model) => ProfileEntity(
        id: model.id,
        name: model.name,
        username: model.username,
        email: model.email,
        role: model.role,
        emailVerifiedAt: model.emailVerifiedAt,
        status: model.status,
        lastLoginAt: model.lastLoginAt,
      );
}
