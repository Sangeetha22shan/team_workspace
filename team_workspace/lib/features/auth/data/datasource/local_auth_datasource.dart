import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_workspace/core/constants/app_constants.dart';
import 'package:team_workspace/core/error/exceptions.dart';

import '../models/user_model.dart';


abstract class LocalAuthDataSource {
  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearCache();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final SharedPreferences _sharedPreferences;

  LocalAuthDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _sharedPreferences.setString(
        AppConstants.userSessionKey,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString =
      _sharedPreferences.getString(AppConstants.userSessionKey);
      if (jsonString == null) return null;

      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _sharedPreferences.remove(AppConstants.userSessionKey);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}