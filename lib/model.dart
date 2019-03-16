import 'package:scoped_model/scoped_model.dart';

class DataModel extends Model {
  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;

  void setLoaded() {
    _hasLoaded = true;
    notifyListeners();
  }
}

