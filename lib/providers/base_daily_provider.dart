import 'package:flutter/foundation.dart';
import '../models/base_task.dart';
import 'base_task_provider.dart';

class BaseDailyProvider with ChangeNotifier {
  final BaseTaskProvider _taskProv;
  BaseDailyProvider(this._taskProv) {
    _taskProv.addListener(_onBaseChanged);
  }

  List<BaseTaskModel> get dailies => _taskProv.dailies;
  bool get loading => _taskProv.loading;
  String? get error => _taskProv.error;

  Future<void> fetch() => _taskProv.fetchBaseTasks();
  Future<bool> complete(BaseTaskModel task) =>
      _taskProv.complete(task);

  void _onBaseChanged() => notifyListeners();
  @override
  void dispose() {
    _taskProv.removeListener(_onBaseChanged);
    super.dispose();
  }
}
