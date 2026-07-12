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
import '../../features/tournament/data/datasource/team_remote_datasource.dart';
import '../../features/tournament/data/repositories/tournament_repository_impl.dart';
import '../../features/tournament/data/repositories/team_repository_impl.dart';
import '../../features/tournament/domain/repositories/tournament_repository.dart';
import '../../features/tournament/domain/repositories/team_repository.dart';
import '../../features/tournament/domain/usecases/get_tournaments_usecase.dart';
import '../../features/tournament/domain/usecases/create_tournament_usecase.dart';
import '../../features/tournament/domain/usecases/get_tournament_meta_usecase.dart';
import '../../features/tournament/domain/usecases/get_teams_usecase.dart';
import '../../features/tournament/domain/usecases/create_team_usecase.dart';
import '../../features/tournament/domain/usecases/get_team_usecase.dart';
import '../../features/tournament/domain/usecases/update_team_usecase.dart';
import '../../features/tournament/domain/usecases/add_player_usecase.dart';
import '../../features/tournament/domain/usecases/get_players_usecase.dart';
import '../../features/tournament/domain/usecases/get_player_usecase.dart';
import '../../features/tournament/domain/usecases/update_player_usecase.dart';
import '../../features/tournament/domain/usecases/delete_team_usecase.dart';
import '../../features/tournament/domain/usecases/delete_player_usecase.dart';
import '../../features/tournament/data/datasource/player_search_datasource.dart';
import '../../features/tournament/data/repositories/player_search_repository_impl.dart';
import '../../features/tournament/domain/repositories/player_search_repository.dart';
import '../../features/tournament/domain/usecases/search_player_usecase.dart';

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

// --- Team ---

final teamRemoteDatasourceProvider = Provider<TeamRemoteDatasource>(
  (ref) => TeamRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) => TeamRepositoryImpl(
    remoteDatasource: ref.read(teamRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getTeamsUseCaseProvider = Provider<GetTeamsUseCase>(
  (ref) => GetTeamsUseCase(ref.read(teamRepositoryProvider)),
);

final createTeamUseCaseProvider = Provider<CreateTeamUseCase>(
  (ref) => CreateTeamUseCase(ref.read(teamRepositoryProvider)),
);

final getTeamUseCaseProvider = Provider<GetTeamUseCase>(
  (ref) => GetTeamUseCase(ref.read(teamRepositoryProvider)),
);

final updateTeamUseCaseProvider = Provider<UpdateTeamUseCase>(
  (ref) => UpdateTeamUseCase(ref.read(teamRepositoryProvider)),
);

final addPlayerUseCaseProvider = Provider<AddPlayerUseCase>(
  (ref) => AddPlayerUseCase(ref.read(teamRepositoryProvider)),
);

final getPlayersUseCaseProvider = Provider<GetPlayersUseCase>(
  (ref) => GetPlayersUseCase(ref.read(teamRepositoryProvider)),
);

final getPlayerUseCaseProvider = Provider<GetPlayerUseCase>(
  (ref) => GetPlayerUseCase(ref.read(teamRepositoryProvider)),
);

final updatePlayerUseCaseProvider = Provider<UpdatePlayerUseCase>(
  (ref) => UpdatePlayerUseCase(ref.read(teamRepositoryProvider)),
);

final deleteTeamUseCaseProvider = Provider<DeleteTeamUseCase>(
  (ref) => DeleteTeamUseCase(ref.read(teamRepositoryProvider)),
);

final deletePlayerUseCaseProvider = Provider<DeletePlayerUseCase>(
  (ref) => DeletePlayerUseCase(ref.read(teamRepositoryProvider)),
);

// --- Player Search ---

final playerSearchDatasourceProvider = Provider<PlayerSearchDatasource>(
  (ref) => PlayerSearchDatasourceImpl(ref.read(apiClientProvider)),
);

final playerSearchRepositoryProvider = Provider<PlayerSearchRepository>(
  (ref) => PlayerSearchRepositoryImpl(
    datasource: ref.read(playerSearchDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final searchPlayerUseCaseProvider = Provider<SearchPlayerUseCase>(
  (ref) => SearchPlayerUseCase(ref.read(playerSearchRepositoryProvider)),
);
