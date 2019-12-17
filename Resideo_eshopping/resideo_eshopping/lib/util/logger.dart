import 'package:logging/logging.dart';
final Logger _logger = () {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  return Logger('Resideo e_shopping');
}();
void info(String label, String log) => _logger.info('[$label] $log');
void error(String label, String log) => _logger.shout('[$label] $log');
void debug(String label,String log) => _logger.fine('[$label] $log');

