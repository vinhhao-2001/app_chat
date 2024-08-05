// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_chat/data/data_mapper/friend_data_mapper.dart' as _i965;
import 'package:app_chat/data/data_mapper/message_data_mapper.dart' as _i228;
import 'package:app_chat/data/data_mapper/user_data_mapper.dart' as _i378;
import 'package:app_chat/data/data_sources/local/db_helper.dart' as _i175;
import 'package:app_chat/data/data_sources/remote/api/api_service.dart'
    as _i1023;
import 'package:app_chat/data/repositories_impl/auth_repository_impl.dart'
    as _i111;
import 'package:app_chat/data/repositories_impl/friend_repository_impl.dart'
    as _i151;
import 'package:app_chat/data/repositories_impl/message_repository_impl.dart'
    as _i1039;
import 'package:app_chat/data/repositories_impl/user_repository_impl.dart'
    as _i584;
import 'package:app_chat/domain/repositories/auth_repository.dart' as _i410;
import 'package:app_chat/domain/repositories/friend_repository.dart' as _i363;
import 'package:app_chat/domain/repositories/message_repository.dart' as _i325;
import 'package:app_chat/domain/repositories/user_repository.dart' as _i210;
import 'package:app_chat/domain/user_cases/auth_uc/check_user_use_case.dart'
    as _i795;
import 'package:app_chat/domain/user_cases/auth_uc/login_use_case.dart'
    as _i466;
import 'package:app_chat/domain/user_cases/auth_uc/logout_use_case.dart'
    as _i821;
import 'package:app_chat/domain/user_cases/auth_uc/register_use_case.dart'
    as _i171;
import 'package:app_chat/domain/user_cases/friend_uc/get_friend_list_use_case.dart'
    as _i599;
import 'package:app_chat/domain/user_cases/message_uc/get_message_list_use_case.dart'
    as _i709;
import 'package:app_chat/domain/user_cases/message_uc/reload_message_use_case.dart'
    as _i693;
import 'package:app_chat/domain/user_cases/message_uc/send_message_use_case.dart'
    as _i680;
import 'package:app_chat/domain/user_cases/shared_uc/add_nickname_use_case.dart'
    as _i679;
import 'package:app_chat/domain/user_cases/shared_uc/download_file_use_case.dart'
    as _i404;
import 'package:app_chat/domain/user_cases/shared_uc/load_avatar_use_case.dart'
    as _i893;
import 'package:app_chat/domain/user_cases/shared_uc/load_image_use_case.dart'
    as _i754;
import 'package:app_chat/domain/user_cases/user_uc/get_user_use_case.dart'
    as _i793;
import 'package:app_chat/domain/user_cases/user_uc/update_user_use_case.dart'
    as _i1022;
import 'package:app_chat/presentation/blocs/chat/chat_bloc.dart' as _i175;
import 'package:app_chat/presentation/blocs/friend/friend_bloc.dart' as _i535;
import 'package:app_chat/presentation/blocs/picker/picker_bloc.dart' as _i807;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i228.MessageDataMapper>(() => _i228.MessageDataMapper());
    gh.factory<_i378.UserDataMapper>(() => _i378.UserDataMapper());
    gh.factory<_i965.FriendDataMapper>(() => _i965.FriendDataMapper());
    gh.factory<_i175.ChatBloc>(() => _i175.ChatBloc());
    gh.factory<_i807.PickerBloc>(() => _i807.PickerBloc());
    gh.lazySingleton<_i175.DatabaseHelper>(() => _i175.DatabaseHelper());
    gh.lazySingleton<_i1023.ApiService>(() => _i1023.ApiService());
    gh.lazySingleton<_i535.FriendBloc>(() => _i535.FriendBloc());
    gh.lazySingleton<_i210.UserRepository>(() => _i584.UserRepositoryImpl(
          gh<_i1023.ApiService>(),
          gh<_i378.UserDataMapper>(),
        ));
    gh.lazySingleton<_i325.MessageRepository>(
        () => _i1039.MessageRepositoryImpl(
              gh<_i1023.ApiService>(),
              gh<_i175.DatabaseHelper>(),
              gh<_i228.MessageDataMapper>(),
            ));
    gh.lazySingleton<_i404.DownloadFileUseCase>(
        () => _i404.DownloadFileUseCase(gh<_i1023.ApiService>()));
    gh.factory<_i793.GetUserUseCase>(
        () => _i793.GetUserUseCase(gh<_i210.UserRepository>()));
    gh.factory<_i1022.UpdateUserUseCase>(
        () => _i1022.UpdateUserUseCase(gh<_i210.UserRepository>()));
    gh.factory<_i709.GetMessageListUseCase>(
        () => _i709.GetMessageListUseCase(gh<_i325.MessageRepository>()));
    gh.factory<_i693.ReloadMessageUseCase>(
        () => _i693.ReloadMessageUseCase(gh<_i325.MessageRepository>()));
    gh.factory<_i680.SendMessageUseCase>(
        () => _i680.SendMessageUseCase(gh<_i325.MessageRepository>()));
    gh.lazySingleton<_i410.AuthRepository>(() => _i111.AuthRepositoryImpl(
          gh<_i1023.ApiService>(),
          gh<_i378.UserDataMapper>(),
        ));
    gh.lazySingleton<_i363.FriendRepository>(() => _i151.FriendRepositoryImpl(
          gh<_i1023.ApiService>(),
          gh<_i965.FriendDataMapper>(),
          gh<_i175.DatabaseHelper>(),
        ));
    gh.factory<_i821.LogoutUseCase>(
        () => _i821.LogoutUseCase(gh<_i175.DatabaseHelper>()));
    gh.factory<_i679.AddNicknameUseCase>(
        () => _i679.AddNicknameUseCase(gh<_i175.DatabaseHelper>()));
    gh.factory<_i893.LoadAvatarUseCase>(() => _i893.LoadAvatarUseCase(
          gh<_i1023.ApiService>(),
          gh<_i175.DatabaseHelper>(),
        ));
    gh.factory<_i754.LoadImageUseCase>(() => _i754.LoadImageUseCase(
          gh<_i1023.ApiService>(),
          gh<_i175.DatabaseHelper>(),
        ));
    gh.factory<_i599.GetFriendListUseCase>(
        () => _i599.GetFriendListUseCase(gh<_i363.FriendRepository>()));
    gh.factory<_i795.CheckUserUseCase>(
        () => _i795.CheckUserUseCase(gh<_i410.AuthRepository>()));
    gh.factory<_i171.RegisterUseCase>(
        () => _i171.RegisterUseCase(gh<_i410.AuthRepository>()));
    gh.factory<_i466.LoginUseCase>(
        () => _i466.LoginUseCase(gh<_i410.AuthRepository>()));
    return this;
  }
}
