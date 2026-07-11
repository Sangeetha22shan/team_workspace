import 'package:logger/logger.dart';


class AnalyticsService {
  final Logger logger;

  AnalyticsService(this.logger);

  Future<void> logAppOpen() async {
    logger.i('analytics: app_open');
  }

  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    logger.i('analytics event: $name -> $parameters');
  }

  Future<void> setUserId(String? id) async {
    logger.i('analytics setUserId: $id');
  }
}

