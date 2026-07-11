import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../api/api_client.dart';
import '../api/dio_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_service.dart';
import '../../features/authentication/data/datasource/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/verify_otp_usecase.dart';
import '../../features/authentication/domain/usecases/resend_otp_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/domain/usecases/verify_forgot_password_otp_usecase.dart';
import '../../features/authentication/domain/usecases/reset_password_usecase.dart';
import '../../features/profile/data/datasource/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/tournament/data/datasource/tournament_remote_datasource.dart';
import '../../features/tournament/data/repositories/tournament_repository_impl.dart';
import '../../features/tournament/domain/repositories/tournament_repository.dart';
import '../../features/tournament/domain/usecases/get_tournaments_usecase.dart';
import '../../features/tournament/domain/usecases/create_tournament_usecase.dart';
import '../../features/tournament/domain/usecases/get_tournament_meta_usecase.dart';

// --- Infrastructure ---

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.read(secureStorageProvider)),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.read(dioClientProvider)),
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(InternetConnection()),
);

// --- Auth ---

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDatasource: ref.read(authRemoteDatasourceProvider),
    storageService: ref.read(secureStorageProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.read(authRepositoryProvider)),
);

final resendOtpUseCaseProvider = Provider<ResendOtpUseCase>(
  (ref) => ResendOtpUseCase(ref.read(authRepositoryProvider)),
);

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.read(authRepositoryProvider)),
);

final verifyForgotPasswordOtpUseCaseProvider =
    Provider<VerifyForgotPasswordOtpUseCase>(
  (ref) => VerifyForgotPasswordOtpUseCase(ref.read(authRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.read(authRepositoryProvider)),
);

// --- Profile ---

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    remoteDatasource: ref.read(profileRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.read(profileRepositoryProvider)),
);

// --- Tournament ---

final tournamentRemoteDatasourceProvider =
    Provider<TournamentRemoteDatasource>(
  (ref) => TournamentRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final tournamentRepositoryProvider = Provider<TournamentRepository>(
  (ref) => TournamentRepositoryImpl(
    remoteDatasource: ref.read(tournamentRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getTournamentsUseCaseProvider = Provider<GetTournamentsUseCase>(
  (ref) => GetTournamentsUseCase(ref.read(tournamentRepositoryProvider)),
);

final createTournamentUseCaseProvider = Provider<CreateTournamentUseCase>(
  (ref) => CreateTournamentUseCase(ref.read(tournamentRepositoryProvider)),
);

final getTournamentMetaUseCaseProvider = Provider<GetTournamentMetaUseCase>(
  (ref) => GetTournamentMetaUseCase(ref.read(tournamentRepositoryProvider)),
);
