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
import '../../features/tournament/domain/usecases/show_tournament_usecase.dart';
import '../../features/tournament/domain/usecases/update_tournament_usecase.dart';
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
import '../../features/tournament/data/datasource/stage_remote_datasource.dart';
import '../../features/tournament/data/repositories/stage_repository_impl.dart';
import '../../features/tournament/domain/repositories/stage_repository.dart';
import '../../features/tournament/domain/usecases/get_stages_usecase.dart';
import '../../features/tournament/domain/usecases/create_stage_usecase.dart';
import '../../features/tournament/domain/usecases/show_stage_usecase.dart';
import '../../features/tournament/domain/usecases/update_stage_usecase.dart';
import '../../features/tournament/domain/usecases/delete_stage_usecase.dart';
import '../../features/tournament/data/datasource/group_remote_datasource.dart';
import '../../features/tournament/data/repositories/group_repository_impl.dart';
import '../../features/tournament/domain/repositories/group_repository.dart';
import '../../features/tournament/domain/usecases/get_groups_usecase.dart';
import '../../features/tournament/domain/usecases/create_group_usecase.dart';
import '../../features/tournament/domain/usecases/show_group_usecase.dart';
import '../../features/tournament/domain/usecases/update_group_usecase.dart';
import '../../features/tournament/domain/usecases/delete_group_usecase.dart';
import '../../features/tournament/domain/usecases/add_group_team_usecase.dart';
import '../../features/tournament/domain/usecases/remove_group_team_usecase.dart';
import '../../features/tournament/data/datasource/round_remote_datasource.dart';
import '../../features/tournament/data/repositories/round_repository_impl.dart';
import '../../features/tournament/domain/repositories/round_repository.dart';
import '../../features/tournament/domain/usecases/get_rounds_usecase.dart';
import '../../features/tournament/domain/usecases/create_round_usecase.dart';
import '../../features/tournament/domain/usecases/delete_round_usecase.dart';
import '../../features/tournament/data/datasource/point_system_remote_datasource.dart';
import '../../features/tournament/data/repositories/point_system_repository_impl.dart';
import '../../features/tournament/domain/repositories/point_system_repository.dart';
import '../../features/tournament/domain/usecases/get_point_systems_usecase.dart';
import '../../features/tournament/domain/usecases/create_point_system_usecase.dart';
import '../../features/tournament/domain/usecases/update_point_system_usecase.dart';
import '../../features/tournament/domain/usecases/delete_point_system_usecase.dart';
import '../../features/tournament/data/datasource/match_remote_datasource.dart';
import '../../features/tournament/data/repositories/match_repository_impl.dart';
import '../../features/tournament/domain/repositories/match_repository.dart';
import '../../features/tournament/domain/usecases/get_matches_usecase.dart';
import '../../features/tournament/domain/usecases/create_match_usecase.dart';
import '../../features/tournament/domain/usecases/update_match_usecase.dart';
import '../../features/tournament/domain/usecases/delete_match_usecase.dart';
import '../../features/tournament/domain/usecases/add_match_team_usecase.dart';
import '../../features/tournament/domain/usecases/remove_match_team_usecase.dart';
import '../../features/tournament/domain/usecases/submit_match_results_usecase.dart';
import '../../features/tournament/domain/usecases/get_match_results_usecase.dart';
import '../../features/tournament/domain/usecases/delete_match_results_usecase.dart';
import '../../features/tournament/data/datasource/leaderboard_remote_datasource.dart';
import '../../features/tournament/data/repositories/leaderboard_repository_impl.dart';
import '../../features/tournament/domain/repositories/leaderboard_repository.dart';
import '../../features/tournament/domain/usecases/get_group_leaderboard_usecase.dart';
import '../../features/tournament/domain/usecases/get_round_leaderboard_usecase.dart';
import '../../features/tournament/domain/usecases/get_stage_leaderboard_usecase.dart';
import '../../features/tournament/domain/usecases/get_tournament_leaderboard_usecase.dart';
import '../../features/tournament/domain/usecases/get_match_leaderboard_usecase.dart';

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

final showTournamentUseCaseProvider = Provider<ShowTournamentUseCase>(
  (ref) => ShowTournamentUseCase(ref.read(tournamentRepositoryProvider)),
);

final updateTournamentUseCaseProvider = Provider<UpdateTournamentUseCase>(
  (ref) => UpdateTournamentUseCase(ref.read(tournamentRepositoryProvider)),
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

// --- Stage ---

final stageRemoteDatasourceProvider = Provider<StageRemoteDatasource>(
  (ref) => StageRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final stageRepositoryProvider = Provider<StageRepository>(
  (ref) => StageRepositoryImpl(
    remoteDatasource: ref.read(stageRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getStagesUseCaseProvider = Provider<GetStagesUseCase>(
  (ref) => GetStagesUseCase(ref.read(stageRepositoryProvider)),
);

final createStageUseCaseProvider = Provider<CreateStageUseCase>(
  (ref) => CreateStageUseCase(ref.read(stageRepositoryProvider)),
);

final showStageUseCaseProvider = Provider<ShowStageUseCase>(
  (ref) => ShowStageUseCase(ref.read(stageRepositoryProvider)),
);

final updateStageUseCaseProvider = Provider<UpdateStageUseCase>(
  (ref) => UpdateStageUseCase(ref.read(stageRepositoryProvider)),
);

final deleteStageUseCaseProvider = Provider<DeleteStageUseCase>(
  (ref) => DeleteStageUseCase(ref.read(stageRepositoryProvider)),
);

// --- Group ---

final groupRemoteDatasourceProvider = Provider<GroupRemoteDatasource>(
  (ref) => GroupRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepositoryImpl(
    remoteDatasource: ref.read(groupRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getGroupsUseCaseProvider = Provider<GetGroupsUseCase>(
  (ref) => GetGroupsUseCase(ref.read(groupRepositoryProvider)),
);

final createGroupUseCaseProvider = Provider<CreateGroupUseCase>(
  (ref) => CreateGroupUseCase(ref.read(groupRepositoryProvider)),
);

final showGroupUseCaseProvider = Provider<ShowGroupUseCase>(
  (ref) => ShowGroupUseCase(ref.read(groupRepositoryProvider)),
);

final updateGroupUseCaseProvider = Provider<UpdateGroupUseCase>(
  (ref) => UpdateGroupUseCase(ref.read(groupRepositoryProvider)),
);

final deleteGroupUseCaseProvider = Provider<DeleteGroupUseCase>(
  (ref) => DeleteGroupUseCase(ref.read(groupRepositoryProvider)),
);

final addGroupTeamUseCaseProvider = Provider<AddGroupTeamUseCase>(
  (ref) => AddGroupTeamUseCase(ref.read(groupRepositoryProvider)),
);

final removeGroupTeamUseCaseProvider = Provider<RemoveGroupTeamUseCase>(
  (ref) => RemoveGroupTeamUseCase(ref.read(groupRepositoryProvider)),
);

// --- Round ---

final roundRemoteDatasourceProvider = Provider<RoundRemoteDatasource>(
  (ref) => RoundRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final roundRepositoryProvider = Provider<RoundRepository>(
  (ref) => RoundRepositoryImpl(
    remoteDatasource: ref.read(roundRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getRoundsUseCaseProvider = Provider<GetRoundsUseCase>(
  (ref) => GetRoundsUseCase(ref.read(roundRepositoryProvider)),
);

final createRoundUseCaseProvider = Provider<CreateRoundUseCase>(
  (ref) => CreateRoundUseCase(ref.read(roundRepositoryProvider)),
);

final deleteRoundUseCaseProvider = Provider<DeleteRoundUseCase>(
  (ref) => DeleteRoundUseCase(ref.read(roundRepositoryProvider)),
);

// --- Point System ---

final pointSystemRemoteDatasourceProvider = Provider<PointSystemRemoteDatasource>(
  (ref) => PointSystemRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final pointSystemRepositoryProvider = Provider<PointSystemRepository>(
  (ref) => PointSystemRepositoryImpl(
    remoteDatasource: ref.read(pointSystemRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getPointSystemsUseCaseProvider = Provider<GetPointSystemsUseCase>(
  (ref) => GetPointSystemsUseCase(ref.read(pointSystemRepositoryProvider)),
);

final createPointSystemUseCaseProvider = Provider<CreatePointSystemUseCase>(
  (ref) => CreatePointSystemUseCase(ref.read(pointSystemRepositoryProvider)),
);

final updatePointSystemUseCaseProvider = Provider<UpdatePointSystemUseCase>(
  (ref) => UpdatePointSystemUseCase(ref.read(pointSystemRepositoryProvider)),
);

final deletePointSystemUseCaseProvider = Provider<DeletePointSystemUseCase>(
  (ref) => DeletePointSystemUseCase(ref.read(pointSystemRepositoryProvider)),
);

// --- Match ---

final matchRemoteDatasourceProvider = Provider<MatchRemoteDatasource>(
  (ref) => MatchRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepositoryImpl(
    remoteDatasource: ref.read(matchRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getMatchesUseCaseProvider = Provider<GetMatchesUseCase>(
  (ref) => GetMatchesUseCase(ref.read(matchRepositoryProvider)),
);

final createMatchUseCaseProvider = Provider<CreateMatchUseCase>(
  (ref) => CreateMatchUseCase(ref.read(matchRepositoryProvider)),
);

final updateMatchUseCaseProvider = Provider<UpdateMatchUseCase>(
  (ref) => UpdateMatchUseCase(ref.read(matchRepositoryProvider)),
);

final deleteMatchUseCaseProvider = Provider<DeleteMatchUseCase>(
  (ref) => DeleteMatchUseCase(ref.read(matchRepositoryProvider)),
);

final addMatchTeamUseCaseProvider = Provider<AddMatchTeamUseCase>(
  (ref) => AddMatchTeamUseCase(ref.read(matchRepositoryProvider)),
);

final removeMatchTeamUseCaseProvider = Provider<RemoveMatchTeamUseCase>(
  (ref) => RemoveMatchTeamUseCase(ref.read(matchRepositoryProvider)),
);

final submitMatchResultsUseCaseProvider = Provider<SubmitMatchResultsUseCase>(
  (ref) => SubmitMatchResultsUseCase(ref.read(matchRepositoryProvider)),
);

final getMatchResultsUseCaseProvider = Provider<GetMatchResultsUseCase>(
  (ref) => GetMatchResultsUseCase(ref.read(matchRepositoryProvider)),
);

final deleteMatchResultsUseCaseProvider = Provider<DeleteMatchResultsUseCase>(
  (ref) => DeleteMatchResultsUseCase(ref.read(matchRepositoryProvider)),
);

// --- Leaderboard ---

final leaderboardRemoteDatasourceProvider = Provider<LeaderboardRemoteDatasource>(
  (ref) => LeaderboardRemoteDatasourceImpl(ref.read(apiClientProvider)),
);

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepositoryImpl(
    remoteDatasource: ref.read(leaderboardRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

final getGroupLeaderboardUseCaseProvider = Provider<GetGroupLeaderboardUseCase>(
  (ref) => GetGroupLeaderboardUseCase(ref.read(leaderboardRepositoryProvider)),
);

final getRoundLeaderboardUseCaseProvider = Provider<GetRoundLeaderboardUseCase>(
  (ref) => GetRoundLeaderboardUseCase(ref.read(leaderboardRepositoryProvider)),
);

final getStageLeaderboardUseCaseProvider = Provider<GetStageLeaderboardUseCase>(
  (ref) => GetStageLeaderboardUseCase(ref.read(leaderboardRepositoryProvider)),
);

final getTournamentLeaderboardUseCaseProvider = Provider<GetTournamentLeaderboardUseCase>(
  (ref) => GetTournamentLeaderboardUseCase(ref.read(leaderboardRepositoryProvider)),
);

final getMatchLeaderboardUseCaseProvider = Provider<GetMatchLeaderboardUseCase>(
  (ref) => GetMatchLeaderboardUseCase(ref.read(leaderboardRepositoryProvider)),
);
