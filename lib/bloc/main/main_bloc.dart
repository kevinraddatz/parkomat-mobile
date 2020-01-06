import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
import 'package:parkomat/data/network/apis/github/github_client.dart';
import 'package:parkomat/data/network/apis/parkomat/parkomat_client.dart';
import 'package:parkomat/data/sharedpref/shared_preference_cache.dart';
import 'package:parkomat/models/parkomat/free_spot_statistics.dart';

part 'main_event.dart';
part 'main_state.dart';

@provide
class MainBloc extends Bloc<MainEvent, MainState> {
  final ParkomatClient _parkomatClient;
  final SharedPreferenceCache _sharedPreferenceCache;
  final GithubClient _githubClient;

  MainBloc(this._parkomatClient, this._sharedPreferenceCache, this._githubClient) {
    this.add(InitMainEvent());
  }

  @override
  MainState get initialState => MainInitialState();

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    String remoteVersion = await _githubClient.getServerVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    if (version != remoteVersion) {
      yield OutdatedVersionMainState(remoteVersion);
    }
    try {
      if (event is InitMainEvent) {
        String baseUrl = await _sharedPreferenceCache.getBaseUrl();
        if (baseUrl == null) {
          yield UnsetMainState();
        } else {
          FreeSpotStatistics stats = await _parkomatClient.getStats(baseUrl);
          yield LoadedMainState(stats, baseUrl);
        }
      }
      if (event is RefreshMainEvent) {
        String baseUrl = await _sharedPreferenceCache.getBaseUrl();
        FreeSpotStatistics stats = await _parkomatClient.getStats(baseUrl);
        yield LoadedMainState(stats, baseUrl);
      }
//      if (event is SetBaseUrlMainEvent) {
//        if (event.replacement) {
//          Navigator.pushReplacement(event.context, RouteBuilder.build(event.context, Routes.settings));
//        } else {
//          Navigator.push(event.context, RouteBuilder.build(event.context, Routes.settings));
//        }
//      }
//      if (event is Error404MainEvent) {
//        Flushbar(
//          message: S.of(event.context).couldNotGetStats,
//          backgroundColor: Colors.red,
//          duration: Duration(seconds: 3),
//        )..show(event.context);
//      }
//      if (event is OutdatedVersionMainEvent) {
//        Flushbar(
//          message: S.of(event.context).outdatedVersion(event.version),
//          backgroundColor: Colors.red,
//          duration: Duration(seconds: 3),
//        )..show(event.context);
//      }
    } on DioError catch (e) {
      if (e.response.statusCode == 404) {
        yield Error404MainState();
      }
    }
  }
}
