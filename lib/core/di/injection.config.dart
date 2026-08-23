// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:poplar/features/restricted_calls/data/repositories/restricted_calls_repository_impl.dart'
    as _i808;
import 'package:poplar/features/restricted_calls/domain/repositories/restricted_calls_repository.dart'
    as _i151;
import 'package:poplar/features/restricted_calls/presentation/bloc/restricted_calls_bloc.dart'
    as _i75;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i151.RestrictedCallsRepository>(
      () => _i808.RestrictedCallsRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i75.RestrictedCallsBloc>(
      () => _i75.RestrictedCallsBloc(gh<_i151.RestrictedCallsRepository>()),
    );
    return this;
  }
}
